extends Control

const ItemModel = preload("res://scenes/ui/inventory/ItemModel.gd")

func received_item(item: ItemModel):
	print_debug("received item ", item)
	pass

func open():
	print_debug("Inventory opened")
	visible = true

func close():
	print_debug("Inventory closed")
	visible = false

func _on_Close_pressed():
	close()
