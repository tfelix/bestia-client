extends KinematicBody
class_name Player

export(float) var speed = 5.0

enum PlayerState {
	IDLE,
	CONSTRUCTING,
	ATTACKING, 
	MOVING
}

var _target: Vector3 = Vector3.INF
var _current_state = PlayerState.IDLE
var entity_kind = Entity.EntityKind.PLAYER

onready var _move_cursor = $MoveCursor
onready var _components = $Components

# Find a way to properly get the entity id
export var id = 1000

func _ready():
	GlobalEvents.connect("onTerrainClicked", self, "_move_player_to")
	GlobalEvents.connect("onStructureConstructionStarted", self, "_started_construction")
	GlobalEvents.connect("onStructureConstructionEnded", self, "_ended_construction")
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
	if _current_state != PlayerState.IDLE || _target == Vector3.INF:
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
	if _current_state != PlayerState.MOVING &&  _current_state != PlayerState.IDLE:
		return
	look_at(global_pos, Vector3.UP)
	_move_cursor.global_transform.origin = global_pos
	_move_cursor.play()
	_target = global_pos


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
