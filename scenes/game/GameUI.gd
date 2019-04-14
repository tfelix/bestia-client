extends Control

signal on_chat_send(text)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_ChatPanel_on_chat_send(text):
	emit_signal("on_chat_send", text)
