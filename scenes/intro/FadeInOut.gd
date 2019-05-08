extends ColorRect

signal fade_out_finished
signal fade_in_finished

var play_backwards = false

func fade():
	$AnimationPlayer.play("fade_in")
	play_backwards = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if play_backwards == false:
		emit_signal("fade_out_finished")
		$AnimationPlayer.play_backwards("fade_in")
		play_backwards = true
	else:
		play_backwards = false
		emit_signal("fade_in_finished")

