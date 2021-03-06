extends Control

const InventoryItemNode = preload("res://UI/Inventory/InventoryItem.tscn")
const ItemDescriptionNode = preload("res://UI/Inventory/ItemDescriptionModule/ItemDescriptionModule.tscn")
const ItemDropDialog = preload("res://UI/Inventory/ItemDropDialog/ItemDropDialog.tscn")

class InventoryInfo:
	var max_weight: int
	var max_items: int

onready var _items_grid = $InventoryPanel/HContainer/MainContent/Content/Panel/Margin/ScrollContainer/ItemGrid
onready var _weight_label = $InventoryPanel/HContainer/MainContent/Header/Weight
onready var _count_label = $InventoryPanel/HContainer/MainContent/Header/MarginItemCount/ItemCount
onready var _search_text = $InventoryPanel/HContainer/MainContent/Header/SearchEdit
onready var _search_clear_btn = $InventoryPanel/HContainer/MainContent/Header/ClearSearch
onready var _module = $InventoryPanel/HContainer/MainContent/Content/Module

var _item_db = ItemDatabase.new()
var _info: InventoryInfo = InventoryInfo.new()

# To check for existence of resources prior to loading.
var _dir = Directory.new()
var _items = []
var _displayed_items = []

var _is_dragged = false
var _mouse_offset = Vector2(0, 0)

var _inventory_open_pre_construction = false
var _item_use_request_id = ""

# New published items will be added to the inventory
# Selected items will be displayed in 
func _ready():
	_info.max_weight = 0
	_info.max_items = 0
	_draw_inventory_info()
	GlobalEvents.connect("onInventoryUpdate", self, "_on_inventory_update")
	GlobalEvents.connect("onItemUsed", self, "use_item")
	GlobalEvents.connect("onStructureConstructionStarted", self, "_construction_started")
	GlobalEvents.connect("onStructureConstructionEnded", self, "_construction_ended")
	GlobalEvents.connect("onShortcutPressed", self, "_on_shortcut_pressed")
	GlobalEvents.connect("onMessageReceived", self, "_on_item_use_response")
	GlobalEvents.connect("onInventoryItemUpdateRequested", self, "_on_item_udpdate_requested")
	
	var msg = RequestInventoryMessage.new()
	GlobalEvents.emit_signal("onMessageSend", msg)
	
	# Setup the initial position
	var win_pos = GlobalConfig.get_value(GlobalConfig.SEC_WIN_POS, GlobalConfig.PROP_WIN_INVENTORY, Vector2(100, 100))
	rect_position = win_pos


func _process(delta):
	if _is_dragged:
		var mouse_pos = get_viewport().get_mouse_position()
		rect_position = mouse_pos - _mouse_offset


func _on_item_udpdate_requested() -> void:
	_emit_items_updated()


func _emit_items_updated() -> void:
	var updated_items = []
	for item in _items:
		updated_items.append(item.data)
	GlobalEvents.emit_signal("onInventoryItemsUpdated", updated_items)


func _on_inventory_update(payload: InventoryUpdateMessage) -> void:
	_info.max_items = payload.max_items
	_info.max_weight = payload.max_weight
	_clear_inventory_items()
	_add_inventory_items(payload.items)
	_display_all_items()
	_draw_inventory_info()
	_emit_items_updated()


func _clear_inventory_items() -> void:
	for item in _items:
		item.queue_free()
	_items.clear()


func _add_inventory_items(items) -> void:
	for item in items:
		var item_info = _item_db.get_data(item.item_id)
		assert(item_info, "ERROR: Could not find data for item_id: %s" % item.item_id)
		item_info.amount = item.amount
		item_info.player_item_id = item.player_item_id
		
		var item_node = InventoryItemNode.instance()
		item_node.data = item_info
		item_node.connect("item_selected", self, "_on_item_selected")
		_items.append(item_node)


func _on_shortcut_pressed(action_name: String, shortcut: ShortcutData) -> void:
	if shortcut.type != ShortcutData.ShortcutType.ITEM:
		return
	var player_item_id = shortcut.payload["player_item_id"]
	use_item(player_item_id)


"""
Tries to use a certain item
"""
func use_item(player_item_id: int) -> void:
	print_debug("use_item with pid ", player_item_id)
	# Make a sanity check if we have items left
	var pi = _get_item(player_item_id)
	if pi == null:
		printerr("ERROR: use_item with pid ", player_item_id, " not found")
		return
	if not pi.data.is_usable() || pi.data.amount < 1:
		printerr("ERROR: use_item with pid ", player_item_id, " not usable or amount < 1")
		return
	# We need to check with the server if the player is actually allowed
	# to use this item. Maybe we can just use it and react on the response?
	var use_msg = ItemUseRequestMessage.new()
	use_msg.player_item_id = player_item_id
	use_msg.request_id = UUID.create()
	_item_use_request_id = use_msg.request_id
	GlobalEvents.emit_signal("onMessageSend", use_msg)


func drop_item(item_data) -> void:
	var item_drop_modal = ItemDropDialog.instance()
	get_tree().root.add_child(item_drop_modal)
	item_drop_modal.ask_drop_amount(item_data)
	item_drop_modal.popup_centered()


func _on_item_use_response(msg: ItemUseResponseMessage) -> void:
	# Small trick on typed param godot delivers null if type does not match
	if not msg:
		return
	
	if not msg.request_id == _item_use_request_id:
		print_debug("ItemUseResponse request id missmatch")
		return
	
	if not msg.can_use:
		print_debug("Can not use item ", msg.player_item_id, " (", msg.request_id  ,")")
		return
	
	# Player is allowed to use this item. Depending on the item we can now
	# display special ui elements or start the construction process.
	# If the item is just a consumable we can just use it.
	var item = _get_item(msg.player_item_id)
	
	if item.data.type == ItemData.ItemType.CONSUMEABLE:
		var use_msg = ItemUseMessage.new()
		use_msg.player_item_id = msg.player_item_id
		GlobalEvents.emit_signal("onMessageSend", use_msg)
		return
	
	var item_name = item.data.database_name.capitalize().replace(" ", "")
	var item_path = "res://Game/Entity/Struct/%s/%s.tscn" % [item_name, item_name]
	assert(_dir.file_exists(item_path), "ERROR: Item scene %s not found" % item_path)
	# TODO We can probably cache these loads here.
	var item_scene = load(item_path)
	var item_instance = item_scene.instance()
	get_tree().root.add_child(item_instance)
	item_instance.start_construct()


"""
Checks if the player goes into item construction mode with opened inventory
if this is the case after the end of construction mode the inventory will re-open
again.
"""
func _construction_started(entity) -> void:
	_inventory_open_pre_construction = self.visible
	hide()


func _construction_ended(entity) -> void:
	if _inventory_open_pre_construction:
		show()


func _get_item(pid: int) -> ItemModel:
	for item in _items:
		if pid == item.data.player_item_id:
			return item
	return null


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
		_items_grid.remove_child(child)
	
	for item in _displayed_items:
		_items_grid.add_child(item)


func _on_item_selected(selected_item) -> void:
	_remove_module()
	# If null we just deselect all items and return.
	if selected_item == null:
		for item_node in _items_grid.get_children():
			item_node.selected = false
		return
	
	for item_node in _items_grid.get_children():
		if selected_item == item_node:
			item_node.selected = !item_node.selected
		else:
			item_node.selected = false
	
	if selected_item.selected:
		var item_desc = ItemDescriptionNode.instance()
		_module.add_child(item_desc)
		item_desc.show_item_description(selected_item)
		_module.visible = true
	else:
		_module.visible = false


func _remove_module() -> void:
	# if there is no child, no need to remove it.
	if _module.get_child_count() == 0:
		return
	var existing_module = _module.get_child(0)
	existing_module.queue_free()


func _draw_inventory_info():
	_count_label.text = str("Items: ", _items.size(), " / ", _info.max_items)
	var cur_weight = get_total_weight()
	var cur_weight_kg = stepify(cur_weight / 10.0, 0.01)
	var max_weight_kg = stepify(_info.max_weight / 10.0, 0.01)
	_weight_label.text = "Weight: %skg / %skg" % [cur_weight_kg, max_weight_kg]


func get_total_weight() -> int:
	var total_weight = 0
	for i in _items:
		total_weight += i.data.weight * i.data.amount
	return total_weight


func hide():
	_on_item_selected(null)
	.hide()


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
	_displayed_items.clear()
	var filter_name_upper = filter_name.to_upper()
	for item in _items:
		# Might be a bit wasteful but we have no proper other way
		# to fetch the databse name.
		var item_node = _get_item(item.data.player_item_id)
		if tr(item_node.data.database_name).to_upper().begins_with(filter_name_upper):
			_displayed_items.append(item)
	_show_displayed_items()


func _unhandled_key_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		hide()
	if event.is_action_pressed("ui_inventory"):
		get_tree().set_input_as_handled()
		if visible:
			hide()
		else:
			show()


func _on_Inventory_mouse_entered():
	GlobalEvents.emit_signal("onUiEntered")


func _on_Inventory_mouse_exited():
	GlobalEvents.emit_signal("onUiExited")


func _put_on_top() -> void:
	var child_count = get_parent().get_child_count()
	get_parent().move_child(self, child_count)


func _on_WindowTitle_drag_started(mouse_offset):
	_mouse_offset = mouse_offset
	_is_dragged = true
	_put_on_top()


func _on_WindowTitle_drag_ended():
	_is_dragged = false
	GlobalConfig.set_value(GlobalConfig.SEC_WIN_POS, GlobalConfig.PROP_WIN_INVENTORY, rect_position)


func _on_WindowTitle_close_clicked():
	hide()
