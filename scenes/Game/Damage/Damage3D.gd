extends RigidBody

var _damage: DamageMessage
var _source_entity: Spatial

onready var _label = $DamageLabel

func init(damage: DamageMessage, entity: Spatial):
	_damage = damage
	_source_entity = entity


func _process(delta):
	var cam = get_tree().get_root().get_camera()
	var pos = self.global_transform.origin
	var viewport_pos = cam.unproject_position(pos)
	_label.set_position(viewport_pos)


func _ready():
	_label.set_text(str(_damage.total_damage))
	match _damage.type:
		DamageMessage.DamageType.DAMAGE, DamageMessage.DamageType.MISS:
			_label.show_normal()
		DamageMessage.DamageType.CRIT:
			_label.show_crit()
		DamageMessage.DamageType.HEAL:
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
	
	if _damage.type == DamageMessage.DamageType.HEAL || _damage.type == DamageMessage.DamageType.MISS:
		vel_x = 0
		vel_y = 15
		gravity_scale = 0
	
	self.linear_velocity = Vector3(vel_x, vel_y, 0)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
