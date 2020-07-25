extends Control

var scene_path_to_load

func _on_FadeIn_fade_out_finished():
	get_tree().change_scene("res://scenes/intro/Intro.tscn")


func _on_DevDocsLink_pressed():
	OS.shell_open("https://docs.bestia-game.net")


func _on_Options_pressed():
	get_tree().change_scene("res://UI/Options/Options.tscn")


func _on_PlayDemo_pressed():
	$FadeIn.show()
	$FadeIn.fade()


func _on_FadeIn_fade_in_finished():
	$FadeIn.hide()
