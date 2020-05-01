extends Control
class_name InventoryItem

const DragItem = preload("res://UI/Inventory/DragItem.tscn")

signal item_selected

var data: ItemData
var selected: bool setget _set_selected


onready var _amount = $Amount
onready var _image = $ItemImage
onready var _select = $SelectHighlight
onready var _hover = $HoverHighlight


func _ready():
	if data != null:
		_image.texture = data.image
		_set_amount(data.amount)


func get_drag_data(position):
	var drag_item = DragItem.instance()
	drag_item.data = data
	set_drag_preview(drag_item)
	
	return data


"""
Can not drop on this item here.
"""
func can_drop_data(position, drop_data) -> bool:
	print_debug(drop_data.get_class())
	return true


func is_usable() -> bool:
	return data.type == ItemData.ItemType.CONSUMEABLE || data.type == ItemData.ItemType.STRUCTURE


func totalWeight() -> int:
	return data.weight * data.amount


func _set_selected(is_selected: bool) -> void:
	_select.visible = is_selected
	selected = is_selected


func _set_amount(new_amount: int) -> void:
	if new_amount > 9999:
		new_amount = 9999
	data.amount = new_amount
	_amount.text = String(new_amount)


func _on_Item_mouse_entered():
	_hover.visible = true


func _on_InventoryItem_mouse_exited():
	_hover.visible = false


func _on_Item_gui_input(event: InputEvent):
	if !event.is_action_pressed("left_click"):
		return
	emit_signal("item_selected", self)
