extends KinematicBody
class_name Player

# TODO Read walkspeed from component
export(float) var speed = 5.0

# Maybe put this in own state node
enum PlayerState {
	IDLE,
	CONSTRUCTING,
	ATTACKING, 
	MOVING,
	CASTING,
	INTERACTING # e.g. talking with npc
}

var _move_target: Vector3 = Vector3.INF
var _current_state = PlayerState.IDLE

var _has_attack_delay = false
var _target_entity: Entity
var _casted_attack = null

onready var _move_cursor = $MoveCursor
onready var _attack_delay = $AttackDelay
onready var _entity = $Entity

func _ready():
	GlobalEvents.connect("onTerrainClicked", self, "_move_to")
	GlobalEvents.connect("onStructureConstructionStarted", self, "_started_construction")
	GlobalEvents.connect("onStructureConstructionEnded", self, "_ended_construction")
	GlobalEvents.connect("onPlayerInteract", self, "_on_player_interact")
	GlobalEvents.connect("onShortcutPressed", self, "_shortcut_pressed")
	
	# This seems to be a bug in godot. in order to get mouse over events
	# we must disable and enable raycasting detection.
	input_ray_pickable = false
	input_ray_pickable = true
	# As we might be already attached under the Entities node it might not
	# be subscribed to the entity signal. To give it a chance to subscribe
	# we need to call announce entity deferred.
	call_deferred("_announce_entity")


func _started_construction(entity) -> void:
	_current_state = PlayerState.CONSTRUCTING


func _ended_construction(entity) -> void:
	_current_state = PlayerState.IDLE


func _physics_process(delta):
	if _current_state != PlayerState.MOVING || _move_target == Vector3.INF:
		_move_target = Vector3.INF
		return
	
	var global_pos = global_transform.origin
	var target_delta = (_move_target - global_pos).length()
	
	if target_delta < 0.1:
		return

	if _move_target == global_pos:
		return

	var velocity = (_move_target - global_pos).normalized() * speed
	move_and_slide_with_snap(velocity, Vector3.UP)


# TODO Later access the real mesh of the player
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3(1, 2.2, 1))


func _move_to(global_pos: Vector3) -> void:
	if _current_state == PlayerState.CONSTRUCTING:
		return
	
	# We cancel casts on hold
	_casted_attack = null
	GlobalEvents.emit_signal("onCastEnded")
	
	look_at(global_pos, Vector3.UP)
	_move_cursor.global_transform.origin = global_pos
	_move_cursor.play()
	_move_target = global_pos
	_current_state = PlayerState.MOVING


func _on_player_interact(target_entity: Entity, type: String) -> void:
	if type == "basic_attack":
		_player_attacks(target_entity)


# TODO React opun which attack was pressed
func _shortcut_pressed(action: String, payload: String) -> void:
	if payload.begins_with("attack-"):
		var data = payload.split("-")
		var attack_id = int(data[1])
		# Haben wir die attacke?
		# Wird die Attacke direkt ausgelöst?
		# Brauchen wir ein Ziel? Ja?
		# - Ggf Cursor austauschen
		# - Marker austauschen?
		_casted_attack = 5
		GlobalEvents.emit_signal("onCastStarted")


func _cast_attack_on_entity(entity) -> void:
	GlobalEvents.emit_signal("onCastEnded")
	
	look_at(entity.global_transform.origin, Vector3.UP)
	_current_state = Vector3.INF
	_current_state = PlayerState.IDLE
	
	var msg = UseAttackMessage.new()
	msg.player_attack_id = 5
	msg.target_entity = entity.id
	GlobalEvents.emit_signal("onMessageSend", msg)


func _player_attacks(target_entity: Entity) -> void:
	if _casted_attack:
		_cast_attack_on_entity(target_entity)
		return
	
	if _has_attack_delay:
		return
	
	var target_origin = target_entity.get_spatial().global_transform.origin
	look_at(target_origin, Vector3.UP)
	
	# Check if in range, if not walk to target
	var weapon_comp = _entity.get_component(WeaponComponent.NAME) as WeaponComponent
	if weapon_comp == null:
		print_debug("No weapon component on player entity")
		return
	
	var target_distance = target_origin.distance_to(global_transform.origin)
	if  weapon_comp.attack_range < target_distance:
		# distance is too short we need to move first.
		print_debug("out of range: ", weapon_comp.attack_range, " < ", target_distance)
		return
	
	_current_state = PlayerState.ATTACKING
	_target_entity = target_entity
	
	# TODO diffeentiate between melee or ranged depending on component
	var atk_msg = UseAttackMessage.new()
	atk_msg.player_attack_id = UseAttackMessage.RANGE_ATTACK_ID
	atk_msg.target_entity = target_entity.id
	GlobalEvents.emit_signal("onMessageSend", atk_msg)

	_has_attack_delay = true
	_attack_delay.wait_time = weapon_comp.attack_delay
	_attack_delay.start()


func _on_Player_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		#_handle_default_input()
		# This is not in the hierarchy of an entity and thus this self value
		# is often not recognized at the receiving site.
		GlobalEvents.emit_signal("onEntityClicked", self, event)
	if event.is_action_pressed(Actions.ACTION_RIGHT_CLICK):
		#_handle_secondary_input()
		pass


func _on_AttackDelay_timeout():
	_has_attack_delay = false
	
	if _current_state == PlayerState.ATTACKING:
		if _target_entity == null:
			_current_state = PlayerState.IDLE
			return
		_player_attacks(_target_entity)
