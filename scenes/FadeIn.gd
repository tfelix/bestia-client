extends ColorRect

signal fade_out_finished
signal fade_in_finished

export var fade_duration_ms: int = 500

const base_duration_ms = 500.0
var is_fade_out = true

func fade():
	is_fade_out = true
	var new_speed = base_duration_ms / fade_duration_ms
	$AnimationPlayer.play("fade_in", -1, new_speed)

func _on_AnimationPlayer_animation_finished(anim_name):
	if is_fade_out:
		is_fade_out = false
		emit_signal("fade_out_finished")
		var new_speed = fade_duration_ms / base_duration_ms
		$AnimationPlayer.play_backwards("fade_in")
	else:
		emit_signal("fade_in_finished")
