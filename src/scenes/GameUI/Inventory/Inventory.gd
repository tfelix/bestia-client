extends Control

const InventoryItemNode = preload("res://scenes/GameUI/Inventory/InventoryItem.tscn")
const ItemDescriptionNode = preload("res://scenes/GameUI/Inventory/ItemDescriptionModule/ItemDescriptionModule.tscn")
const ItemEquipModule = preload("res://scenes/GameUI/Inventory/ItemEquipModule/ItemEquipModule.tscn")

const placeholder_img = preload("res://scenes/GameUI/Inventory/item_placeholder.png")

class InventoryInfo:
	var max_weight: int
	var max_items: int

onready var _pickup_msg = $ItemPickupMessage
onready var _items_grid = $MarginContainer/InventoryPanel/HContainer/MainContent/Content/Panel/Margin/ScrollContainer/ItemGrid
onready var _weight_label = $MarginContainer/InventoryPanel/HContainer/MainContent/Header/Weight
onready var _count_label = $MarginContainer/InventoryPanel/HContainer/MainContent/Header/MarginItemCount/ItemCount
onready var _search_text = $MarginContainer/InventoryPanel/HContainer/MainContent/Header/SearchEdit
onready var _search_clear_btn = $MarginContainer/InventoryPanel/HContainer/MainContent/Header/ClearSearch
onready var _module = $MarginContainer/InventoryPanel/HContainer/MainContent/Content/Module
onready var _inventory_mode_btn = $MarginContainer/InventoryPanel/HContainer/Categories/InventoryMode
onready var _equip_mode_btn = $MarginContainer/InventoryPanel/HContainer/Categories/EquipMode

const item_db_file = "res://scenes/Game/Entity/Item/item_database.json"

# Maybe do this by convention
var _item_infos = { }

var _info: InventoryInfo = InventoryInfo.new()
var _items = []
var _displayed_items = []
var _inventory_open_pre_construction = false

# New published items will be added to the inventory
# Selected items will be displayed in 
func _ready():
	_load_item_db()
	_info.max_weight = 0
	_info.max_items = 0
	_draw_inventory_info()
	GlobalEvents.connect("onInventoryUpdate", self, "_on_inventory_update")
	GlobalEvents.connect("onItemUsed", self, "_use_item")
	GlobalEvents.connect("onStructureConstructionStarted", self, "_construction_started")
	GlobalEvents.connect("onStructureConstructionEnded", self, "_construction_ended")
	GlobalEvents.connect("onShortcutPressed", self, "_on_shortcut_pressed")
	
	var msg = RequestInventoryMessage.new()
	GlobalEvents.emit_signal("onMessageSend", msg)



func _load_item_db() -> void:
	var file = File.new()
	file.open(item_db_file, file.READ)
	var text = file.get_as_text()
	_item_infos = parse_json(text)
	file.close()


func _on_inventory_update(payload: InventoryUpdateMessage) -> void:
	_info.max_items = payload.max_items
	_info.max_weight = payload.max_weight
	update_inventory_items(payload.items)


func _on_shortcut_pressed(action_name: String, shortcut: ShortcutData) -> void:
	if not shortcut.type == "item":
		return
	var player_item_id = shortcut.payload["player_item_id"]
	_use_item(player_item_id)


"""
Tries to use a certain item
"""
func _use_item(player_item_id)-> void:
	print_debug("use_shortcut_item with pid ", player_item_id)
	# Make a sanity check if we have items left
	var pi = _get_item_node(player_item_id)
	if pi == null:
		print_debug("use_shortcut_item with pid ", player_item_id, " not found")
		return
	if pi.is_usable() != true || pi.amount < 1:
		print_debug("use_shortcut_item with pid ", player_item_id, " not usable")
		return
	# TODO We need to check by the server if the player is actually allowed to
	# use the item
	var use_msg = ItemUseMessage.new()
	use_msg.player_item_id = player_item_id
	GlobalEvents.emit_signal("onMessageSend", use_msg)


func _on_item_use_response(msg: ItemUseResponseMessage) -> void:
	if !msg.can_use:
		print_debug("Can not use item ", msg.player_item_id, " (", msg.request_id  ,")")
		return
	
	# Player is allowed to use this item. Depending on the item we can now
	# display special ui elements or start the construction process.
	#var item_name = item.database_name.capitalize().replace(" ", "")
	#var item_path = "res://scenes/Game/Entity/Struct/%s/%s.tscn" % [item_name, item_name.to_lower()]
	#var item_scene = load(item_path)
	#var item_instance = item_scene.instance()
	#get_tree().root.add_child(item_instance)
	#item_instance.start_construct()


"""
Checks if the player goes into item construction mode with opened inventory
if this is the case after the end of construction mode the inventory will re-open
again
"""
func _construction_started() -> void:
	_inventory_open_pre_construction = self.visible
	hide()


func _construction_ended() -> void:
	if _inventory_open_pre_construction:
		show()


func _get_item(pid: int) -> ItemModel:
	for item in _items:
		if pid == item.player_item_id:
			return item
	return null

"""
Returns the inventory node item.
"""
func _get_item_node(pid: int) -> InventoryItem:
	for item in _items_grid.get_children():
		if item.player_item_id == pid:
			return item
	return null


func update_inventory_items(items: Array) -> void:
	_items = items
	_display_all_items()
	_draw_inventory_info()


func _check_item_still_selected() -> void:
	var existing_item_desc = _module.get_childweig(0)
	if existing_item_desc != null && existing_item_desc is ItemDescriptionModule:
		var selected_item = existing_item_desc.item as ItemModel
		for item in _items:
			if selected_item.player_item_id == item.player_item_id:
				return
		# It seems the selected item is not in the inventory anymore. So 
		# we de-select it.
		_remove_module()


func _show_displayed_items() -> void:
	for child in _items_grid.get_children():
		child.queue_free()
	
	for item in _displayed_items:
		var key = String(item.item_id)
		if not _item_infos.has(key):
			continue
		
		var item_info = _item_infos[key]
		var item_node = InventoryItemNode.instance()
		
		item_node.amount  = item.amount
		item_node.player_item_id = item.player_item_id
		item_node.weight = item_info.weight
		item_node.database_name = item_info.database_name
		match item_info["type"]:
			"consumeable":
				item_node.type = InventoryItem.ItemType.CONSUMEABLE
			"structure":
				item_node.type = InventoryItem.ItemType.STRUCTURE
			"equip":
				item_node.type = InventoryItem.ItemType.EQUIP
			_:
				item_node.type = InventoryItem.ItemType.ETC
		item_node.item_id = item.item_id
		
		var name = tr(item_info.database_name.to_upper())
		var description = tr((item_info.database_name + "_description").to_upper())
		
		var image_path = _database_name_to_image_path(item_info.database_name)
		item_node.image = load(image_path)
		if item_node.image == null:
			item_node.image = placeholder_img
		
		_items_grid.add_child(item_node)
		item_node.connect("item_selected", self, "_on_item_selected")


func _database_name_to_image_path(_database_name: String) -> String:
	var base_path = "res://scenes/Game/Entity/Item/"
	var cleaned_db_name = _database_name.capitalize().replace(" ", "")
	
	return base_path + cleaned_db_name + "/" + cleaned_db_name + ".png"


func _on_item_selected(item_node) -> void:
	for child in _items_grid.get_children():
		if child == item_node:
			child.selected = !child.selected
		else:
			child.selected = false
	
	_remove_module()
	
	if item_node.selected:
		var item_desc = ItemDescriptionNode.instance()
		_module.add_child(item_desc)
		item_desc.show_item_description(item_node)
		_module.visible = true
	else:
		_module.visible = false


func _remove_module() -> void:
	var existing_module = _module.get_child(0)
	if existing_module != null:
		existing_module.queue_free()


func _draw_inventory_info():
	_count_label.text = str("Items: ", _items.size(), " / ", _info.max_items)
	var cur_weight_kg = stepify(get_total_weight() / 10.0, 0.01)
	var max_weight_kg = stepify(_info.max_weight / 10.0, 0.01)
	_weight_label.text = str("Weight: ", cur_weight_kg, "kg / ", max_weight_kg, "kg")


func get_total_weight() -> int:
	var total_weight = 0
	for i in _items:
		var item_node = _get_item_node(i.player_item_id)
		total_weight += item_node.weight
	return total_weight


func received_item(item: ItemModel):
	_pickup_msg.show_message(item)
	_items.push(item)
	_draw_inventory_info()


func hide():
	if visible:
		$AudioClick.play()
	.hide()


func show():
	if not visible:
		$AudioClick.play()
	.show()


func _on_Close_pressed():
	hide()


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


func _on_EquipMode_pressed():
	_inventory_mode_btn.disabled = false
	_equip_mode_btn.disabled = true
	_remove_module()
	var equip_module = ItemEquipModule.instance()
	_module.add_child(equip_module)
	_module.visible = true


func _on_InventoryMode_pressed():
	_inventory_mode_btn.disabled = true
	_equip_mode_btn.disabled = false
	_remove_module()


func _unhandled_key_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		hide()
	if event.is_action_pressed("ui_inventory_open"):
		if visible:
			hide()
		else:
			show()


func _on_Inventory_mouse_entered():
	GlobalEvents.emit_signal("onUiEntered")


func _on_Inventory_mouse_exited():
	GlobalEvents.emit_signal("onUiExited")
