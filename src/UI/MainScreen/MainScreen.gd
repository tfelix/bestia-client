extends Control

var scene_path_to_load
onready var _fader = $SceneFade

export var bgm_music: AudioStream


func _ready():
	GlobalAudio.update_volumes()
	GlobalAudio.play_bgm(bgm_music)
	GlobalVideo.update_video()


func _on_DevDocsLink_pressed():
	OS.shell_open("https://docs.bestia-game.net")


func _on_Options_pressed():
	get_tree().change_scene("res://UI/Options/Options.tscn")


func _on_PlayDemo_pressed():
	_fader.fade()


func _on_FadeIn_fade_in_finished():
	_fader.hide()


func _on_SceneFade_fade_out_finished():
	get_tree().change_scene("res://UI/Intro/Intro.tscn")
