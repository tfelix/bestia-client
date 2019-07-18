extends RigidBody

var DamageType = load("res://scenes/Game/Damage/Damage.gd").DamageType

var _damage
var _source_entity: Spatial

onready var _label = $Viewport/DamageLabelGUI

func init(damage, entity: Spatial):
	_damage = damage
	_source_entity = entity

func _ready():
	_label.set_text(str(_damage.amount))
	match _damage.type:
		DamageType.DAMAGE, DamageType.MISS:
			_label.show_normal()
		DamageType.CRIT:
			_label.show_crit()
		DamageType.HEAL:
			_label.show_heal()
	_prepare_velocity()


func _prepare_velocity():
	var vel_x = randf() * 3 + 2
	var vel_y = 20
	if _source_entity != null:
		var own_pos = get_parent().transform.origin
		var delta_x = own_pos.x - _source_entity.transform.origin.x
		vel_x *= sign(delta_x)
	else:
		vel_x *= -1
	
	if _damage.type == DamageType.HEAL || _damage.type == DamageType.MISS:
		vel_x = 0
		vel_y = 15
		gravity_scale = 0
	
	self.linear_velocity = Vector3(vel_x, vel_y, 0)

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
