extends Spatial


var _projectile_speed = 5.0
var _target: Spatial


func start(projectile_speed: float, target: Spatial) -> void:
	_projectile_speed = projectile_speed
	_target = target
	look_at(_target.global_transform.origin, Vector3.UP)


func _process(delta):
	# TODO Improve this behavior
	var offset = Vector3(0, 1.0, 0.0)
	var distance = (_target.global_transform.origin + offset - global_transform.origin).normalized() * _projectile_speed * delta
	global_transform.origin += distance


func _on_Area_body_entered(body: Node):
	var parent = body.get_parent()
	while parent != null:
		if parent == _target:
			print_debug("hit!")
			queue_free()
		parent = parent.get_parent()
	
