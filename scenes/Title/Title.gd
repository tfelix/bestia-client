extends Control

var scene_path_to_load
onready var _version_label = $Menu/VersionLabel

func _ready():
	var file = File.new()
	var dir = "res://version.res"
	if file.file_exists(dir):
		file.open(dir, File.READ)
		var input = file.get_as_text()
		_version_label.text = "v " + input

func _on_GameButton_on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade()

func _on_FadeIn_fade_out_finished():
	get_tree().change_scene("res://scenes/intro/Intro.tscn")
