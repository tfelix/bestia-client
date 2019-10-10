extends Control

const ItemNode = preload("res://scenes/GameUI/Inventory/Item.tscn")
const ItemDescriptionNode = preload("res://scenes/GameUI/Inventory/ItemDescriptionModule.tscn")

class InventoryInfo:
	var max_weight: int
	var max_items: int

onready var _pickup_msg = $ItemPickupMessage
onready var _items_grid = $MarginContainer/InventoryPanel/HContainer/MainContent/Content/Panel/Margin/ScrollContainer/ItemGrid
onready var _weight_label = $MarginContainer/InventoryPanel/HContainer/MainContent/Weight
onready var _count_label = $MarginContainer/InventoryPanel/HContainer/MainContent/ItemCount
onready var _search_text = $MarginContainer/InventoryPanel/HContainer/MainContent/Header/SearchEdit
onready var _search_clear_btn = $MarginContainer/InventoryPanel/HContainer/MainContent/Header/ClearSearch
onready var _module = $MarginContainer/InventoryPanel/HContainer/MainContent/Content/Module

var _info: InventoryInfo = InventoryInfo.new()
var _items = []
var _displayed_items = []

# New published items will be added to the inventory
# Selected items will be displayed in 

func _ready():
	_info.max_weight = 50
	_info.max_items = 200
	_draw_inventory_info()
	# This is a test and will display items
	var test_items = []
	var item1 = ItemModel.new()
	item1.database_name = "empty_bottle"
	item1.weight = 1
	item1.amount = 1
	item1.type = ItemModel.ItemType.ETC
	test_items.append(item1)
	var item2 = ItemModel.new()
	item2.database_name = "knife"
	item2.weight = 5
	item2.amount = 3
	item2.type = ItemModel.ItemType.ETC
	test_items.append(item2)
	var item3 = ItemModel.new()
	item3.database_name = "simple_axe"
	item3.weight = 10
	item3.amount = 1
	item3.type = ItemModel.ItemType.EQUIP
	test_items.append(item3)
	update_inventory_items(test_items)
	
func update_inventory_items(items: Array):
	_items = items
	_display_all_items()
	_draw_inventory_info()


func _show_displayed_items() -> void:
	for child in _items_grid.get_children():
		child.queue_free()
	
	for item in _displayed_items:
		var name = tr(item.database_name.to_upper())
		var description = tr((item.database_name + "_description").to_upper())
		var imagePath = ItemModel.database_name_to_image_path(item.database_name)
		item.image = load(imagePath)
		var item_node = ItemNode.instance()
		_items_grid.add_child(item_node)
		item_node.item = item
		item_node.connect("item_selected", self, "_on_item_selected")


func _on_item_selected(item_node) -> void:
	for child in _items_grid.get_children():
		if child == item_node:
			child.selected = !child.selected
		else:
			child.selected = false
	
	var existing_item_desc = _module.get_child(0)
	if existing_item_desc != null:
		existing_item_desc.queue_free()
	
	if item_node.selected:
		var item_desc = ItemDescriptionNode.instance()
		_module.add_child(item_desc)
		item_desc.show_item_description(item_node.item)
		_module.visible = true
	else:
		_module.visible = false


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


func _on_ClearSearch_pressed():
	_search_text.clear()
	_search_clear_btn.disabled = true


func _on_SearchEdit_text_changed(new_text: String) -> void: 
	if new_text.length() > 0:
		_search_clear_btn.disabled = false
		_filter_displayed_items(new_text)
	else:
		_display_all_items()
		_search_clear_btn.disabled = true
		_show_displayed_items()


func _display_all_items() -> void:
	_displayed_items.clear()
	for item in _items:
		_displayed_items.append(item)
	_show_displayed_items()


func _filter_displayed_items(filter_name: String) -> void:
	print_debug(filter_name)
	_displayed_items.clear()
	var filter_name_upper = filter_name.to_upper()
	for item in _items:
		if tr(item.database_name).to_upper().begins_with(filter_name_upper):
			_displayed_items.append(item)
	_show_displayed_items()
