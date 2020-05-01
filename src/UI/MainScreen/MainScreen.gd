extends Control

var scene_path_to_load
#onready var _version_label = $Menu/VersionLabel

func _ready():
	if ProjectSettings.has_setting("application/config/version"):
		pass
		#_version_label.text = "v " + ProjectSettings.get("application/config/version")

func _on_GameButton_on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade()

func _on_FadeIn_fade_out_finished():
	get_tree().change_scene("res://scenes/intro/Intro.tscn")


func _on_Credits_pressed():
	OS.shell_open("https://docs.bestia-game.net")
	pass # Replace with function body.
