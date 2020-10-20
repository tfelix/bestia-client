extends Spatial

export var y_offset: float
export var movement_speed: Vector2 = Vector2(1.0, 0)

onready var ray = $RayCast

func _physics_process(delta) -> void:
	var terrain = ray.get_collider()
	global_transform.origin.x += delta * movement_speed.x
	global_transform.origin.z += delta * movement_speed.y
	if terrain == null:
		return
	var collision = ray.get_collision_point()
	global_transform.origin.y = collision.y + y_offset
