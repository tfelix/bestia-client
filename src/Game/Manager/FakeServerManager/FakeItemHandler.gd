extends Node
class_name FakeItemHandler

var _player_items = []

func setup() -> void:
	var item1 = ItemModel.new()
	item1.item_id = 1
	item1.player_item_id = 1
	item1.amount = 10
	_player_items.append(item1)
	
	var item2 = ItemModel.new()
	item2.item_id = 2
	item2.player_item_id = 2
	item2.amount = 3
	_player_items.append(item2)
	
	var item3 = ItemModel.new()
	item3.item_id = 4
	item3.player_item_id = 3
	item3.amount = 1
	_player_items.append(item3)
	
	var item4 = ItemModel.new()
	item4.item_id = 4
	item4.player_item_id = 4
	item4.amount = 1
	#_player_items.append(item4)
	
	var item5 = ItemModel.new()
	item5.item_id = 5
	item5.player_item_id = 5
	item5.amount = 5
	#_player_items.append(item5)


func _find_item_pos(item_id: int) -> int:
	var idx = -1
	var i = 0
	for item in _player_items:
		if item.id == item_id:
			idx = i
			break
		i += 1
	return idx


func use_item(msg: ItemUseMessage) -> void:
	var player_item = _get_player_item(msg.player_item_id)
	if player_item == null:
		print_debug("Item with player_item_id ", msg.player_item_id, " not found")
		return

	player_item.amount -= 1

	# APPLE
	if msg.player_item_id == 1:
		_use_apple()
	
	if player_item.amount <= 0:
		_remove_player_item(player_item)
	else:
		send_items()


func _use_apple() -> void:
	var dmg_msg = DamageMessage.new()
	dmg_msg.entity_id = 1
	dmg_msg.total_damage = 15

	var fx_msg = FxMessage.new()
	fx_msg.target_id = 1
	fx_msg.fx = "heal"
	fx_msg.damage = dmg_msg
	fx_msg.latency_ms = 10
	GlobalEvents.emit_signal("onMessageReceived", fx_msg)


func _get_player_item(player_item_id) -> ItemModel:
	for item in _player_items:
		if item.player_item_id  == player_item_id:
			return item
	return null


func _remove_player_item(player_item: ItemModel) -> void:
	_player_items.erase(player_item)
	send_items()


func drop_item(msg: ItemDropMessage) -> void:
	var item = _get_player_item(msg.player_item_id)
	
	if not item:
		print_debug("Could not find player_item_id: ", msg.player_item_id)
		return
	
	item.amount -= msg.amount
	if item.amount <= 0:
		_remove_player_item(item)
	send_items()
	
	
	var info = GlobalData.item_db.get_data(item.item_id)
	var item_entity_id = GlobalData.get_new_entity_id()
	
	var visual_data = ComponentData.new()
	visual_data.entity_id = item_entity_id
	visual_data.component_name = VisualComponent.NAME
	visual_data.data["visual"] = "item/%s" % info["visual"]
	visual_data.data["animation"] = "spawn"
	GlobalEvents.emit_signal("onMessageReceived", visual_data)
	
	var pos_data = ComponentData.new()
	pos_data.entity_id = item_entity_id
	pos_data.component_name = PositionComponent.NAME
	pos_data.data["x"] = 5
	pos_data.data["y"] = 0
	pos_data.data["z"] = 4
	GlobalEvents.emit_signal("onMessageReceived", pos_data)

func send_items() -> void:
	var update_msg = InventoryUpdateMessage.new()
	update_msg.items = _player_items
	# TODO calculate weight based on player strength
	update_msg.max_items = 200
	update_msg.max_weight = 500
	GlobalEvents.emit_signal("onMessageReceived", update_msg)


func request_item_use(msg: ItemUseRequestMessage) -> void:
	var response = ItemUseResponseMessage.new()
	# TODO Build a proper test for the items found in the demo
	response.can_use = true
	response.player_item_id = msg.player_item_id
	response.request_id = msg.request_id
	GlobalEvents.emit_signal("onMessageReceived", response)
