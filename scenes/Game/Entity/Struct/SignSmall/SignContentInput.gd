extends Control

signal text_entered

onready var _input = $CenterContainer/VBoxContainer/HBoxContainer/LineEdit

func _on_SendButton_pressed():
	emit_signal("text_entered", _input.text)
	hide()
