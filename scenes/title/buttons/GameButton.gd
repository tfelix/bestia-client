extends "res://scenes/title/buttons/MenuButton.gd"

func _ready():
	connect("pressed", self, "_on_Button_pressed")

func _on_Button_pressed():
	$BestiaAudio.play()

func _on_GameButton_pressed():
	print_debug("Geht")
	pass # Replace with function body.
