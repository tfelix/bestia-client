extends RigidBody
class_name Damage3D

var _damage: DamageMessage
var _random_offset

onready var _normal = $DamageLabelNormal
onready var _crit = $DamageLabelCrit
onready var _miss = $DamageLabelMiss
onready var _heal = $DamageLabelHeal
onready var _hit_sound = $HitAudio
onready var _heal_sound = $HealAudio

func init(damage: DamageMessage):
	_damage = damage
	set_as_toplevel(true)


func _ready():
	match _damage.type:
		DamageMessage.DamageType.DAMAGE:
			_normal.visible = true
			_normal.set_text(str(_damage.total_damage))
			_crit.visible = false
			_miss.visible = false
			_heal.visible = false
			_hit_sound.play()
		DamageMessage.DamageType.MISS:
			_normal.visible = false
			_crit.visible = false
			_miss.visible = true
			_heal.visible = false
		DamageMessage.DamageType.CRIT:
			_normal.visible = false
			_crit.visible = true
			_crit.set_text(str(_damage.total_damage))
			_miss.visible = false
			_heal.visible = false
			_hit_sound.play()
		DamageMessage.DamageType.HEAL:
			_normal.visible = false
			_crit.visible = false
			_miss.visible = false
			_heal.visible = true
			_heal.set_text(str(_damage.total_damage))
			_heal_sound.play()
	_prepare_velocity()


func _prepare_velocity():
	var cam = get_tree().get_root().get_camera()
	var vel_x = randf() * 1.5 + 2
	var vel_y = randi() % 3 + 16
	var view_pos_owner = cam.unproject_position(get_parent().global_transform.origin)

	if view_pos_owner.x < get_viewport().size.x / 2:
		vel_x *= -1
	
	match(_damage.type):
		DamageMessage.DamageType.HEAL, DamageMessage.DamageType.MISS:
			vel_x = 0
			vel_y = 5
			gravity_scale = 0
	
	self.linear_velocity = Vector3(vel_x, vel_y, 0)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
