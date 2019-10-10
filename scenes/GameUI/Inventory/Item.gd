extends Control

var item: ItemModel setget _set_item

onready var _amount = $Amount
onready var _image = $ItemImage


func _set_item(new_value: ItemModel) -> void:
	item = new_value
	set_amount(item.amount)
	set_image(item.image)


func set_image(image: Texture) -> void:
	_image.texture = image


func set_amount(amount: int) -> void:
	_amount.text = String(amount)


func _on_Item_mouse_entered():
	print_debug("mouse over")
	pass # Replace with function body.


func _on_Item_gui_input(event: InputEvent):
	if !event.is_action_pressed("left_click"):
		return
	print_debug("item selected/clicked")
