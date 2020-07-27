extends Control

signal finished()

onready var _player = $AnimationPlayer

func start():
	_player.play("scroll_image")


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("finished")
