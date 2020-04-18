extends Spatial
class_name Arrow

export var speed = 5.0
export var steer_force = 50.0

var _velocity = Vector3.ZERO
var _accelleration = Vector3.ZERO

var _target: Entity = null
var _y_offset = 0
var _hit_damage


func start(position: Vector3, target: Entity, damage: DamageMessage) -> void:
	global_transform.origin = position
	_target = target
	_hit_damage = damage
	_y_offset = _target.get_aabb().size.y / 0.75


func _physics_process(delta):
	_accelleration += seek()
	_velocity += _accelleration * delta
	_velocity = _velocity.normalized() * clamp(_velocity.length(), 0, speed)
	global_transform.origin += _velocity * delta
	var target_pos = _target.get_spatial().global_transform.origin
	target_pos.y += _y_offset
	look_at(target_pos, Vector3.UP)


func seek() -> Vector3:
	var steer = Vector3.ZERO
	if _target:
		var target_pos = _target.get_spatial().global_transform.origin
		target_pos.y += _y_offset
		var desired = (target_pos - global_transform.origin).normalized() * speed
		steer = (desired - _velocity).normalized() * steer_force
	return steer


# Kill the node for safety if it does not hit.
func _on_DeathTimer_timeout():
	queue_free()


func _on_Hit_body_entered(body):
	var parent = body.get_parent()
	while parent != null:
		if parent == _target:
			GlobalEvents.emit_signal("onDamageReceived", _hit_damage)
			break
		parent = parent.get_parent()
	queue_free()
