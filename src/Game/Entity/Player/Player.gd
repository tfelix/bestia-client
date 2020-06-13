extends KinematicBody
class_name Player

# Maybe put this in own state node
enum PlayerState {
	IDLE,
	CONSTRUCTING,
	ATTACKING, 
	MOVING,
	USE,
	INTERACTING # e.g. talking with npc
}

var _move_target: Vector3 = Vector3.INF
var _current_state = PlayerState.IDLE

var _has_attack_delay = false
var _target_entity: Entity = null

var _queued_casted_attack = null

onready var _model = $Mannequiny
onready var _move_cursor = $MoveCursor
onready var _attack_delay = $AttackDelay
onready var _entity = $Entity

func _ready():
	GlobalEvents.connect("onPlayerMoved", self, "_terrain_clicked")
	GlobalEvents.connect("onStructureConstructionStarted", self, "_started_construction")
	GlobalEvents.connect("onStructureConstructionEnded", self, "_ended_construction")
	GlobalEvents.connect("onPlayerInteract", self, "_on_player_interact")
	GlobalEvents.connect("onSkillCasted", self, "_cast_attack_on_entity")
	
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
		_current_state = PlayerState.IDLE
		_model.is_moving = false
		_model.transition_to(Mannequiny.States.IDLE)
		_check_queued_actions()
		return

	if _move_target == global_pos:
		return

	var status_comp = _entity.get_component(StatusComponent.NAME) as StatusComponent
	var speed = 5.0
	if status_comp != null:
		speed = status_comp.walkspeed
	var velocity = (_move_target - global_pos).normalized() * speed
	
	move_and_slide_with_snap(velocity, Vector3.UP)


func _cast_attack_on_entity(attack, entity, target) -> void:
	look_at(entity.global_transform.origin, Vector3.UP)
	_current_state = Vector3.INF
	_current_state = PlayerState.IDLE


func _check_queued_actions() -> void:
	match _current_state:
		PlayerState.ATTACKING:
			if _target_entity != null:
				_attack(_target_entity)
		PlayerState.USE:
			if _target_entity != null:
				_use(_target_entity)
		_:
			pass


func _clear_queued_actions() -> void:
	_current_state = PlayerState.IDLE


# TODO Later access the real mesh of the player
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3(1, 2.2, 1))


func _terrain_clicked(global_pos: Vector3) -> void:
	# We ignore movement clicks if we are currently constructing
	if _current_state == PlayerState.CONSTRUCTING:
		return
	_play_move_marker(global_pos)
	_move_to(global_pos)


func _move_to(global_pos: Vector3) -> void:
	# If the entity is currently marked as non movable we stop movement here.
	if _entity.get_component(NoMovementComponent.NAME) != null:
		return

	# We cancel possible casts on hold
	_queued_casted_attack = null
	GlobalEvents.emit_signal("onCastSelectionEnded")
	
	look_at(global_pos, Vector3.UP)
	_move_target = global_pos
	_clear_queued_actions()
	_current_state = PlayerState.MOVING
	_model.is_moving = true
	_model.transition_to(Mannequiny.States.RUN)


func _play_move_marker(position: Vector3) -> void:
	_move_cursor.global_transform.origin = position
	_move_cursor.play()


func _on_player_interact(target_entity: Entity, type: String) -> void:
	if type == "basic_attack":
		_attack(target_entity)
	elif type == "use":
		_use(target_entity)


func _use(target_entity: Entity) -> void:
	# Check if we are in usable range.
	# Yes, use item -> call use on structure.
	# No, try to close distance and re-check usability
	var target_origin = target_entity.get_spatial().global_transform.origin
	var target_distance = target_origin.distance_to(global_transform.origin)
	
	var in_use_range = false
	if  not in_use_range:
		_current_state = PlayerState.USE
		_target_entity = target_entity
		_move_to_distance_from_entity(0.1, target_entity)
		return


func _attack(target_entity: Entity) -> void:
	if _has_attack_delay:
		return
	
	var target_origin = target_entity.get_spatial().global_transform.origin
	look_at(target_origin, Vector3.UP)
	
	# Check if in range, if not walk to target
	var weapon_comp = _entity.get_component(WeaponComponent.NAME) as WeaponComponent
	if weapon_comp == null:
		print_debug("No weapon component on player entity")
		return
	
	# Check if we need to move towards our target before we can perform the attack
	var target_distance = target_origin.distance_to(global_transform.origin)
	if  weapon_comp.attack_range < target_distance:
		_move_to_distance_from_entity(weapon_comp.attack_range, target_entity)
		_target_entity = target_entity
		return
	
	_current_state = PlayerState.ATTACKING
	_target_entity = target_entity
	
	# TODO diffeentiate between melee or ranged depending on equip component
	var atk_msg = UseAttackMessage.new()
	atk_msg.player_attack_id = UseAttackMessage.RANGE_ATTACK_ID
	atk_msg.target_entity = target_entity.id
	GlobalEvents.emit_signal("onMessageSend", atk_msg)

	_has_attack_delay = true
	_attack_delay.wait_time = weapon_comp.attack_delay
	_attack_delay.start()


func _move_to_distance_from_entity(distance: float, target_entity: Entity) -> void:
	# We want to keep some safety margin for rounding errors.
	distance -= 0.5
	var target_origin = target_entity.get_spatial().global_transform.origin
	var offset_vec = (target_origin - global_transform.origin).normalized() * distance
	var target = target_origin - offset_vec
	_move_to(target)


func _on_AttackDelay_timeout():
	_has_attack_delay = false
	
	if _current_state == PlayerState.ATTACKING:
		if _target_entity == null:
			_current_state = PlayerState.IDLE
			return
		_attack(_target_entity)
