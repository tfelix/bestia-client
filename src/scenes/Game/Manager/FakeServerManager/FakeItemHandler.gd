class_name FakeItemHandler

var _player_items = []
var _item_db = ItemDatabase.new()

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


func use_item(msg: ItemUseMessage) -> void:
	var player_item = _get_player_item(msg.player_item_id)
	if player_item == null:
		print_debug("Item with player_item_id ", msg.player_item_id, " not found")
		return

	player_item.amount -= 1
	if player_item.amount <= 0:
		# Remove the item from the array
		pass

	# APPLE
	if msg.player_item_id == 1:
		# Heal the player for 15 HP
		print_debug("server: player used apple")

	send_items()


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
	
	
	var info = _item_db.get_data(item.item_id)
	var item_entity_id = GlobalData.get_new_entity_id()
	
	var visual_comp = VisualComponent.new()
	visual_comp.entity_id = item_entity_id
	visual_comp.visual = info["visual"]
	visual_comp.type = "item"
	visual_comp.animation = "spawn"
	GlobalEvents.emit_signal("onMessageReceived", visual_comp)
	
	var pos_comp = PositionComponent.new()
	pos_comp.entity_id = item_entity_id
	pos_comp.x = 5
	pos_comp.y = 0
	pos_comp.z = 4
	GlobalEvents.emit_signal("onMessageReceived", pos_comp)

func send_items() -> void:
	var update_msg = InventoryUpdateMessage.new()
	update_msg.items = _player_items
	# TODO calculate weight based on player strength
	update_msg.max_items = 200
	update_msg.max_weight = 500
	GlobalEvents.emit_signal("onMessageReceived", update_msg)
