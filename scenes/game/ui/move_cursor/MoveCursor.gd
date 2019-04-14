extends Spatial

func animate():
	print_debug($AnimationPlayer.get_animation_list())
	# Strangely the animation sucks. Maybe need to imrpove this when
	# reworking on the arrow.
	# $AnimationPlayer.play()
	$Cube.visible = true
	$Timer.start()

func _on_AnimationPlayer_animation_finished(anim_name):
	$Cube.visible = false

func _on_Timer_timeout():
	$Cube.visible = false
