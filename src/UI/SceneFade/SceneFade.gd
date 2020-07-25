extends ColorRect

signal fade_out_finished
signal fade_in_finished

enum FadeDirection {
	FADE_IN,
	FADE_OUT
}

export var fade_duration_ms: int = 500
export(FadeDirection) var fade_direction = FadeDirection.FADE_IN

const base_duration_ms = 500.0

onready var _player = $AnimationPlayer

func fade():
	visible = true
	var new_speed = base_duration_ms / fade_duration_ms
	
	if fade_direction == FadeDirection.FADE_IN:
		_player.play("fade_in", -1, -new_speed, true)
	else:
		_player.play("fade_in", -1, new_speed)


func _on_AnimationPlayer_animation_finished(anim_name):
	if fade_direction == FadeDirection.FADE_OUT:
		emit_signal("fade_out_finished")
	else:
		emit_signal("fade_in_finished")
