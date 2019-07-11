extends RigidBody

func init(damage):
	$Viewport/DamageLabelGUI/DamageLabel.text = damage


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
