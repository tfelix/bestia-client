extends Spatial

signal slope_exceeded(is_sloop_exceeded)

export(int, 0, 90, 1) var max_slope = 5
export(AABB) var bounding_box = AABB(Vector3(0, 0, 0), Vector3(10, 10, 10)) setget bounding_box_set

onready var cast1 = $RayCast1
onready var cast2 = $RayCast2
onready var cast3 = $RayCast3
onready var cast4 = $RayCast4

var _slope_exceeded = false

func bounding_box_set(new_value):
	bounding_box = new_value
	_position_caster()


func _position_caster() -> void:
	# bounding_box.position
	# cast1.transform.translated()
	# cast2.transform.translated()
	# cast3.transform.translated()
	# cast4.transform.translated()
	pass


func _set_slope_exceeded(flag: bool) -> void:
	if _slope_exceeded != flag:
		_slope_exceeded = flag
		emit_signal("slope_exceeded", flag)


func _physics_process(delta):
	var all_have_contact = cast1.is_colliding() && cast2.is_colliding() && cast3.is_colliding() && cast4.is_colliding() 
	if not all_have_contact:
		_set_slope_exceeded(true)
	var cp1 = cast1.get_collision_point()
	var cp2 = cast2.get_collision_point()
	var cp3 = cast3.get_collision_point()
	var cp4 = cast4.get_collision_point()
	var max_z = max(max(max(cp1.y, cp2.y), cp3.y), cp4.y)
	var min_z = min(min(min(cp1.y, cp2.y), cp3.y), cp4.y)
	
	var is_exceeded = (max_z / min_z) > (1 + (max_slope / 100.0))
	_set_slope_exceeded(is_exceeded)
