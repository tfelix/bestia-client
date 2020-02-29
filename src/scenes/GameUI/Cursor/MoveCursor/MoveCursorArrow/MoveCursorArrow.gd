extends Spatial

func play():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("ArrowMotion")
