extends Spatial
class_name Attack

var hit_damage: DamageMessage
var entity

onready var _player = $AnimationPlayer

func display_damage() -> void:
	if hit_damage:
		GlobalEvents.emit_signal("onDamageReceived", hit_damage)
	# The point where damage is displayed can be considered the
	# end of VFX animation.
	entity.emit_signal("vfx_played", null)


func start(target_entity: Entity, damage: DamageMessage) -> void:
	hit_damage = damage
	entity = target_entity
	target_entity.emit_signal("vfx_played", name)
	_start_animation()


"""
Is called when the animation starts. Can be overwritten if different animations
should be played.
"""
func _start_animation() -> void:
	_player.play("vfx")


"""
Is called when the animation has finished. Can be overwritten to change the
way the cleanup is performed.
"""
func _end_animation() -> void:
	queue_free()


func _on_AnimationPlayer_animation_finished(anim_name):
	_end_animation()
