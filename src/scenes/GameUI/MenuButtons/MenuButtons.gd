extends Control

signal on_inventory_pressed
signal on_attacks_pressed


func _on_Inventory_pressed():
	emit_signal("on_inventory_pressed")


func _on_Attacks_pressed():
	emit_signal("on_attacks_pressed")
