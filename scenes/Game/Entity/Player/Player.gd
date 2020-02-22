extends KinematicBody
class_name Player

export(float) var speed = 5.0

var _target: Vector3 = Vector3.INF
var _can_move: bool = true

onready var _move_cursor = $MoveCursor


func _ready():
	GlobalEvents.connect("onTerrainClicked", self, "_move_player_to")
	GlobalEvents.connect("onEntityClicked", self, "_attack_entity")


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


# TODO Later access the real mesh of the player
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3(1, 2.2, 1))


func _attack_entity(entity: Entity) -> void:
	pass


func _move_player_to(global_pos: Vector3) -> void:
	look_at(global_pos, Vector3.UP)
	_move_cursor.global_transform.origin = global_pos
	_move_cursor.play()
	_target = global_pos
