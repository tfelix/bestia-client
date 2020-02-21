extends KinematicBody
class_name Player

export(float) var speed = 5.0

var _target: Vector3 = Vector3.INF
var _can_move: bool = true

onready var _move_cursor = $MoveCursor

func _ready():
	PubSub.subscribe(PST.TERRAIN_CLICKED, self)
	PubSub.subscribe(PST.PLAYER_MOVE_REQUSTED, self)


func _physics_process(delta):
	if !_can_move || _target == Vector3.INF:
		_target = Vector3.INF
		return
	
	var global_pos = global_transform.origin
	
	if (_target - global_pos).length() < 0.01:
		pass

	if _target == global_pos:
		return
	
	var velocity = (_target - global_pos).normalized() * speed
	move_and_slide (velocity, Vector3.UP)


func free():
  PubSub.unsubscribe(self)
  .free()


# TODO Later access the real mesh of the player
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3(1, 2.2, 1))


func event_published(event_key, payload) -> void:
	match (event_key):
		PST.TERRAIN_CLICKED, PST.PLAYER_MOVE_REQUSTED:
			if !_can_move:
				return
			_move_player_to(payload)


func _move_player_to(global_pos: Vector3) -> void:
	look_at(global_pos, Vector3.UP)
	#var player_pos_2d = Vector2(global_transform.origin.x, global_transform.origin.z)
	#var target_pos_2d = Vector2(global_pos.x, global_pos.z)
	#var angle = player_pos_2d.angle_to(target_pos_2d)
	#print_debug(angle)
	# transform = transform.rotated(Vector3.UP, angle)
	
	_move_cursor.global_transform.origin = global_pos
	_move_cursor.play()
	_target = global_pos
