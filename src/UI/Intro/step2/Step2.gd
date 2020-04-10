extends Control

signal finished()

func start():
	$AnimationPlayer.play("scroll_image")

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("finished")
