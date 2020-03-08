extends Spatial

export var projectile_speed = 5.0
var _target: Entity

func start(target: Entity) -> void:
	_target = target
	look_at(_target.get_spatial().global_transform.origin, Vector3.UP)


func _process(delta):
	# TODO Improve this behavior
	var offset = Vector3(0, 1.0, 0.0)
	var target_origin = _target.get_spatial().global_transform.origin
	var distance = (target_origin + offset - global_transform.origin).normalized() * projectile_speed * delta
	global_transform.origin += distance


func _on_Area_body_entered(body: Node):
	var parent = body.get_parent()
	while parent != null:
		if parent == _target:
			var dmg_msg = DamageMessage.new()
			GlobalEvents.emit_signal("onProjectileHit", _target, dmg_msg)
			queue_free()
		parent = parent.get_parent()
	
