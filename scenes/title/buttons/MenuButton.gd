extends Button

export(String) var scene_to_load = ""

signal on_Button_pressed(scene_to_load)

func _ready():
	connect("pressed", self, "on_Button_pressed", [scene_to_load])