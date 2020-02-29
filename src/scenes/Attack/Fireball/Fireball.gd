extends Spatial

onready var _fireball = $FireballMesh

const velocity = 5.5

func _process(delta) -> void:
	if _fireball == null:
		return
	var d_s = velocity * delta
	var d_pos = d_s * _fireball.translation.normalized()
	var new_pos = _fireball.translation - d_pos
	
	if new_pos.length() < 0.25:
		queue_free()
	
	_fireball.look_at_from_position(new_pos, Vector3.ZERO, Vector3.BACK)


func _on_HitArea_body_entered(body) -> void:
	pass # Replace with function body.
