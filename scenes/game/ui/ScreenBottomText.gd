extends Control
class_name ScreenBottomText

onready var label = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Label
onready var close_botton = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/CloseButton
var text_to_set

func _ready():
	label.set_text(text_to_set)
	close_botton.grab_focus()

func _on_CloseButton_pressed():
	queue_free()
	
func set_text(text):
	text_to_set = text