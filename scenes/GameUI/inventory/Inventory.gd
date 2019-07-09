extends Control

const ItemModel = preload("res://scenes/GameUI/inventory/ItemModel.gd")

func received_item(item: ItemModel):
	# Inventory should show the item obtained message
	print_debug("received item ", item)
	pass

func open():
	print_debug("Inventory opened")
	$AudioClick.play()
	visible = true

func close():
	print_debug("Inventory closed")
	$AudioClick.play()
	visible = false

func _on_Close_pressed():
	close()
