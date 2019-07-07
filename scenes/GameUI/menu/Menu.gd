extends VBoxContainer

signal inventory_clicked()

func _on_Inventory_pressed():
	emit_signal("inventory_clicked")
