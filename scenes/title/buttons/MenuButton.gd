extends Button

export(String) var scene_to_load = ""

signal on_Button_pressed(scene_to_load)

func _on_MenuButton_pressed():
	emit_signal("on_Button_pressed", scene_to_load)
