extends Control

var item: ItemModel setget _set_item
var selected: bool setget _set_selected

onready var _amount = $Amount
onready var _image = $ItemImage
onready var _select = $SelectHighlight

signal item_selected

func _set_selected(is_selected: bool) -> void:
	_select.visible = is_selected
	selected = is_selected


func _set_item(new_value: ItemModel) -> void:
	item = new_value
	_set_amount(item.amount)
	_set_image(item.image)


func _set_image(image: Texture) -> void:
	_image.texture = image


func _set_amount(amount: int) -> void:
	_amount.text = String(amount)


func _on_Item_mouse_entered():
	print_debug("mouse over")
	pass # Replace with function body.


func _on_Item_gui_input(event: InputEvent):
	if !event.is_action_pressed("left_click"):
		return
	emit_signal("item_selected", self)
