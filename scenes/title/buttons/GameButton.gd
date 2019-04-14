extends "res://scenes/title/buttons/MenuButton.gd"

func _on_GameButton_on_Button_pressed(scene_to_load):
	$BestiaAudio.play()


func _on_BestiaAudio_finished():
	pass # Replace with function body.
