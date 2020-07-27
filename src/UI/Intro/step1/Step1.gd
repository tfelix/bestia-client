extends Control

signal finished()

onready var _player = $AnimationPlayer

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("finished")


func start():
	_player.play("animation")
