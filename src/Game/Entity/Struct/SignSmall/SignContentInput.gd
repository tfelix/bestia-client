extends Control

signal text_entered

export (String) var placeholder = "Placeholder"

onready var _input = $PanelContainer/VBoxContainer/HBoxContainer/SignText

func _ready():
	_input.placeholder_text = placeholder
	_input.grab_focus()


func _set_text(text) -> void:
	emit_signal("text_entered", text)
	hide()


func _on_SendButton_pressed():
	_set_text(_input.text)


func _on_LineEdit_text_entered(new_text):
	_set_text(new_text)
