extends Control

var scene_path_to_load

func _on_GameButton_on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade()

func _on_FadeIn_fade_out_finished():
	get_tree().change_scene("res://scenes/intro/Intro.tscn")
