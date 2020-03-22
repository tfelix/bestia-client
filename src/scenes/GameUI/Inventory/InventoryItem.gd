extends Control
class_name InventoryItem

var selected: bool setget _set_selected

enum ItemType {
	CONSUMEABLE,
	STRUCTURE,
	EQUIP,
	ETC
}

export var database_name: String
export(ItemType) var type = ItemType.ETC
export var weight: int = 10
export var item_id: int

var amount: int = 1
var player_item_id: int = 0

onready var _amount = $Amount
onready var _image = $ItemImage
onready var _select = $SelectHighlight
onready var _hover = $HoverHighlight

signal item_selected


func is_usable() -> bool:
	return type == ItemType.CONSUMEABLE || type == ItemType.STRUCTURE


func totalWeight() -> int:
	return weight * amount


func _set_selected(is_selected: bool) -> void:
	_select.visible = is_selected
	selected = is_selected


func _set_image(image: Texture) -> void:
	_image.texture = image


func _set_amount(new_amount: int) -> void:
	if new_amount > 9999:
		new_amount = 9999
	amount = new_amount
	_amount.text = String(new_amount)


func _on_Item_mouse_entered():
	_hover.visible = true


func _on_InventoryItem_mouse_exited():
	_hover.visible = false


func _on_Item_gui_input(event: InputEvent):
	if !event.is_action_pressed("left_click"):
		return
	emit_signal("item_selected", self)
