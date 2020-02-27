extends RigidBody

var _damage: DamageMessage
var _source_entity: Spatial
var _random_offset: Vector2

onready var _label = $DamageLabel


func init(damage: DamageMessage, entity: Spatial):
	_damage = damage
	_source_entity = entity
	_random_offset = Vector2(randi() % 20 - 10, randi() % 50 - 25)


func _process(_delta):
	_position_label()


func _position_label():
	var cam = get_tree().get_root().get_camera()
	var pos = self.global_transform.origin
	var viewport_pos = cam.unproject_position(pos)
	_label.set_position(viewport_pos + _random_offset)


func _ready():
	_label.set_text(str(_damage.total_damage))
	match _damage.type:
		DamageMessage.DamageType.DAMAGE, DamageMessage.DamageType.MISS:
			_label.show_normal()
		DamageMessage.DamageType.CRIT:
			_label.show_crit()
		DamageMessage.DamageType.HEAL:
			_label.show_heal()
	_position_label()
	_prepare_velocity()


func _prepare_velocity():
	var vel_x = randf() * 1.5 + 2
	var vel_y = 18
	if _source_entity != null:
		var own_pos = get_parent().global_transform.origin
		var delta_x = own_pos.x - _source_entity.global_transform.origin.x
		if get_viewport().size.x / 2 > _label.rect_position.x:
			vel_x *= -1
	
	if _damage.type == DamageMessage.DamageType.HEAL || _damage.type == DamageMessage.DamageType.MISS:
		vel_x = 0
		vel_y = 15
		gravity_scale = 0
	
	self.linear_velocity = Vector3(vel_x, vel_y, 0)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
