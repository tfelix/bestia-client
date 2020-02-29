extends KinematicBody
class_name Player

const Arrow = preload("res://scenes/Game/Projectile/Arrow.tscn")

# Read walkspeed from component
export(float) var speed = 5.0

# Maybe put this in own state node
enum PlayerState {
	IDLE,
	CONSTRUCTING,
	ATTACKING, 
	MOVING
}

var _target: Vector3 = Vector3.INF
var _current_state = PlayerState.IDLE

var _has_attack_delay = false
var _target_entity: Entity

var entity_kind = Entity.EntityKind.PLAYER

onready var _move_cursor = $MoveCursor
onready var _components = $Components
onready var _attack_delay = $AttackDelay

# Find a way to properly get the entity id
export var id = 1000

func _ready():
	GlobalEvents.connect("onTerrainClicked", self, "_move_player_to")
	GlobalEvents.connect("onStructureConstructionStarted", self, "_started_construction")
	GlobalEvents.connect("onStructureConstructionEnded", self, "_ended_construction")
	GlobalEvents.connect("onPlayerInteract", self, "_on_player_interact")
	GlobalData.player_entity = self
	
	# This seems to be a bug in godot. in order to get mouse over events
	# we must disable and enable raycasting detection.
	input_ray_pickable = false
	input_ray_pickable = true
	GlobalEvents.emit_signal("onEntityAdded", self)


func _started_construction(entity) -> void:
	_current_state = PlayerState.CONSTRUCTING


func _ended_construction(entity) -> void:
	_current_state = PlayerState.IDLE


func _physics_process(delta):
	if _current_state != PlayerState.MOVING || _target == Vector3.INF:
		_target = Vector3.INF
		return
	
	var global_pos = global_transform.origin
	var target_delta = (_target - global_pos).length()
	
	if target_delta < 0.1:
		return

	if _target == global_pos:
		return

	var velocity = (_target - global_pos).normalized() * speed
	move_and_slide_with_snap(velocity, Vector3.UP)


# TODO Later access the real mesh of the player
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3(1, 2.2, 1))


func _move_player_to(global_pos: Vector3) -> void:
	if _current_state == PlayerState.CONSTRUCTING:
		return
	look_at(global_pos, Vector3.UP)
	_move_cursor.global_transform.origin = global_pos
	_move_cursor.play()
	_target = global_pos
	_current_state = PlayerState.MOVING


func _on_player_interact(target_entity: Entity, type: String) -> void:
	if type == "basic_attack":
		_player_attacks(target_entity)


func _player_attacks(target_entity) -> void:
	_has_attack_delay = true
	var weapon_comp: WeaponComponent = _components.get_component(WeaponComponent.NAME)
	
	# Check if in range, if not walk to target
	
	_current_state = PlayerState.ATTACKING
	_target_entity = target_entity
	
	look_at(_target_entity.global_transform.origin, Vector3.UP)
	
	# Spawn projectile on damage notify
	var arrow = Arrow.instance()
	target_entity.add_child(arrow)
	arrow.global_transform.origin = global_transform.origin
	arrow.start(weapon_comp.projectile_speed, target_entity)
	
	var atk_msg = UseAttackMessage.new()
	atk_msg.player_attack_id = UseAttackMessage.RANGE_ATTACK_ID
	atk_msg.target_entity = target_entity.id
	GlobalEvents.emit_signal("onSendToServer", atk_msg)

	_attack_delay.wait_time = weapon_comp.attack_delay
	_attack_delay.start()


func _on_Player_mouse_entered():
	_components.on_mouse_entered(self)
	GlobalEvents.emit_signal("onEntityMouseEntered", self)


func _on_Player_mouse_exited():
	_components.on_mouse_exited(self)
	GlobalEvents.emit_signal("onEntityMouseExited", self)


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
			_current_state == PlayerState.IDLE
			return
		_player_attacks(_target_entity)
