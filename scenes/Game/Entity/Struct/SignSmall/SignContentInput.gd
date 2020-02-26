extends Control

signal text_entered

export (String) var placeholder = "Placeholder"

onready var _input = $CenterContainer/PanelContainer/VBoxContainer/HBoxContainer/LineEdit

func _ready():
	_input.placeholder_text = placeholder

func _on_SendButton_pressed():
	emit_signal("text_entered", _input.text)
	hide()


func _on_LineEdit_text_entered(new_text):
	emit_signal("text_entered", new_text)
	hide()
