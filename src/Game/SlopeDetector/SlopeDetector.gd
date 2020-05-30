extends Spatial
class_name SlopeDetector

signal slope_exceeded(is_slope_exceeded)

export(int, 0, 90, 1) var max_slope = 5
export(AABB) var bounding_box = AABB(Vector3(0, 0, 0), Vector3(10, 10, 10)) setget bounding_box_set

onready var _cast1 = $RayCast1
onready var _cast2 = $RayCast2
onready var _cast3 = $RayCast3
onready var _cast4 = $RayCast4

var _slope_exceeded = false

func bounding_box_set(new_value):
	bounding_box = new_value
	_position_caster()


func _position_caster() -> void:
	_cast1.translation = Vector3(0,0,0)
	_cast2.translation = Vector3(0,0,0)
	_cast3.translation = Vector3(0,0,0)
	_cast4.translation = Vector3(0,0,0)


func _set_slope_exceeded(flag: bool) -> void:
	if _slope_exceeded != flag:
		_slope_exceeded = flag
		emit_signal("slope_exceeded", flag)


func _physics_process(delta):
	var all_have_contact = _cast1.is_colliding() && _cast2.is_colliding() && _cast3.is_colliding() && _cast4.is_colliding() 
	if not all_have_contact:
		_set_slope_exceeded(true)
	var cp1 = _cast1.get_collision_point()
	var cp2 = _cast2.get_collision_point()
	var cp3 = _cast3.get_collision_point()
	var cp4 = _cast4.get_collision_point()
	var max_z = max(max(max(cp1.y, cp2.y), cp3.y), cp4.y)
	var min_z = min(min(min(cp1.y, cp2.y), cp3.y), cp4.y)
	
	var is_exceeded = (max_z / min_z) > (1 + (max_slope / 100.0))
	_set_slope_exceeded(is_exceeded)
