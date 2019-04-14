extends ColorRect

signal fade_out_finished
signal fade_in_finished

var play_backwards = false

func fade():
	print_debug("fade")
	$AnimationPlayer.play("fade_in")
	play_backwards = false

func _on_AnimationPlayer_animation_finished():
	if play_backwards == false:
		print_debug("fade_out_finished")
		emit_signal("fade_out_finished")
		$AnimationPlayer.play_backwards("fade_in")
		play_backwards = true
	else:
		print_debug("fade_in_finished")
		play_backwards = false
		emit_signal("fade_in_finished")

