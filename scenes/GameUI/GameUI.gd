extends Control

signal on_chat_send(text)

func _on_ChatPanel_on_chat_send(text):
	emit_signal("on_chat_send", text)

func _on_CharacterPlate_on_inventory_pressed():
	$Inventory.open()
