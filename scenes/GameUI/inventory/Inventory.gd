extends Control

const ItemModel = preload("res://scenes/GameUI/Inventory/ItemModel.gd")

class InventoryInfo:
	var max_weight: int
	var max_items: int

onready var _pickup_msg = $ItemPickupMessage
onready var _items_container = $PanelContainer/Content/Items
onready var _weight_label = $PanelContainer/Content/Categories/Weight
onready var _count_label = $PanelContainer/Content/Categories/ItemCount

var _info: InventoryInfo
var _items = []

func _ready():
	_info = InventoryInfo.new()
	_info.max_weight = 50
	_info.max_items = 200
	_draw_inventory_info()
	var item_icon = load("res://placeholder.png")
	_items_container.add_icon_item(item_icon, true)

func update_inventory_info(info: InventoryInfo):
	_info = info
	_draw_inventory_info()

func _draw_inventory_info():
	_count_label.text = str("Items: ", _items.size(), " / ", _info.max_items)
	var cur_weight_kg = stepify(get_total_weight() / 10.0, 0.01)
	var max_weight_kg = stepify(_info.max_weight / 10.0, 0.01)
	_weight_label.text = str("Weight: ", cur_weight_kg, "kg / ", max_weight_kg, "kg")

func get_total_weight() -> int:
	var total_weight = 0
	for i in _items:
		total_weight += i.weight
	return total_weight

func received_item(item: ItemModel):
	_pickup_msg.show_message(item)
	_items.push(item)
	_draw_inventory_info()

func open():
	$AudioClick.play()
	visible = true

func close():
	$AudioClick.play()
	visible = false

func _on_Close_pressed():
	close()
