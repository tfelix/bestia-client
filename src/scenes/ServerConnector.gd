extends Node
class_name ServerConnector

"""
Manages the server send messages. It can re-send it with a proper event.

It acts as a distribution layer and holds the connection to the server.
"""
func _ready():
	GlobalEvents.connect("onMessageReceived", self, "_on_message_received")


func _on_message_received(message) -> void:
	if message is ChatMessage:
		GlobalEvents.emit_signal("onChatReceived", message)
	elif message is InventoryUpdateMessage:
		GlobalEvents.emit_signal("onInventoryUpdate", message)
