extends RigidBody

var _damage
var _source_entity: Spatial

func init(damage, entity: Spatial):
	_damage = damage
	_source_entity = entity

func _ready():
	# $Viewport/DamageLabelGUI/DamageLabel.text = _damage.amount
	var vel_offset = randf() * 3 + 2
	if _source_entity != null:
		var own_pos = get_parent().transform.origin
		var delta_x = own_pos.x - _source_entity.transform.origin.x
		vel_offset *= sign(delta_x)
	else:
		vel_offset *= -1
	self.linear_velocity = Vector3(vel_offset, 20, 0)

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
