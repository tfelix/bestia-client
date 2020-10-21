extends Control

const intro_scene = "res://UI/Intro/Intro.tscn"
const character_editor = "res://UI/CharacterCreation/CharacterCreation.tscn"

export var bgm_music: AudioStream

onready var _fader = $SceneFade

var _load_scene = intro_scene

func _ready():
	GlobalAudio.update_volumes()
	GlobalAudio.play_bgm(bgm_music)
	GlobalVideo.update_video()
	_check_character_config()


func _on_DevDocsLink_pressed():
	OS.shell_open("https://docs.bestia-game.net")


func _on_Options_pressed():
	get_tree().change_scene("res://UI/Options/Options.tscn")


func _on_PlayDemo_pressed():
	_fader.fade()


func _on_FadeIn_fade_in_finished():
	_fader.hide()


func _on_SceneFade_fade_out_finished():
	get_tree().change_scene(_load_scene)


func _check_character_config():
	var file = File.new()
	file.open("user://character.dat", File.READ)
	if file.file_exists("user://character.dat"):
		_load_scene = intro_scene
	else:
		_load_scene = character_editor
	
