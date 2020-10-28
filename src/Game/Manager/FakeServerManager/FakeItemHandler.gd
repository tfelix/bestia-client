extends Node
class_name FakeItemHandler

var _server_manager
export var fake_server_manager_path: NodePath

var _item_db = ItemDatabase.new()
var _player_items = []
var _spawned_entity_items = {}

func _ready() -> void:
	assert(fake_server_manager_path != "", "ERROR: You must give fake_server_manager_path a FakeServerManager node!")
	_server_manager = get_node(fake_server_manager_path)
	GlobalEvents.connect("onEntityAdded", self, "_register_spawned_item")
	GlobalEvents.connect("onEntityRemoved", self, "_remove_spawned_item")


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


func _register_spawned_item(entity: Entity) -> void:
	# This is a crude hack and wont work if entity is not added
	# directly under the root object (which is usually the case)
	if not entity.get_parent() is Item:
		return
	print_debug("Adding item entity: ", entity.id)
	_spawned_entity_items[entity.id] = entity


func _remove_spawned_item(entity: Entity) -> void:
		# This is a crude hack and wont work if entity is not added
	# directly under the root object (which is usually the case)
	if not entity.get_parent() is Item:
		return
	print_debug("Removing item entity: ", entity.id)
	_spawned_entity_items.erase(entity.id)


func _find_item_pos(item_id: int) -> int:
	var idx = -1
	var i = 0
	for item in _player_items:
		if item.id == item_id:
			idx = i
			break
		i += 1
	return idx


func pick_item(msg: PickupItemRequestMessage) -> void:
	var item_entity = _spawned_entity_items[msg.entity_id]
	assert(item_entity != null, "ERROR: Spawned item not found")
	
	var pickup = ItemModel.new()
	pickup.item_id = 5
	pickup.player_item_id = msg.entity_id + 50
	pickup.amount = 1
	_player_items.append(pickup)
	send_items()
	
	var remove_entity_msg = EntityRemoveMessage.new()
	remove_entity_msg.entity_id = msg.entity_id
	GlobalEvents.emit_signal("onMessageReceived", remove_entity_msg)


func use_item(msg: ItemUseMessage) -> void:
	var player_item = _get_player_item(msg.player_item_id)
	if player_item == null:
		print_debug("Item with player_item_id ", msg.player_item_id, " not found")
		return

	player_item.amount -= 1

	# APPLE
	if msg.player_item_id == 1:
		_use_apple()
	else:
		printerr("Used non usable item")
		return
	
	if player_item.amount <= 0:
		_remove_player_item(player_item)
	send_items()


func _use_apple() -> void:
	var dmg_msg = DamageMessage.new()
	dmg_msg.entity_id = 1
	dmg_msg.type = DamageMessage.DamageType.HEAL
	dmg_msg.total_damage = 15

	var fx_msg = FxMessage.new()
	fx_msg.target_id = 1
	fx_msg.fx = "heal"
	fx_msg.damage = dmg_msg
	fx_msg.latency_ms = 10
	GlobalEvents.emit_signal("onMessageReceived", fx_msg)
	
	var player = GlobalData.entities.get_entity(GlobalData.client_account_id)
	var player_cond = player.get_component(ConditionComponent.NAME) as ConditionComponent
	player_cond.cur_health += 15
	if player_cond.cur_health >= player_cond.max_health:
		player_cond.cur_health = player_cond.max_health
	
	var cond_data = ComponentData.new()
	cond_data.entity_id = player.id
	cond_data.component_name = ConditionComponent.NAME
	cond_data.data["cur_health"] = player_cond.cur_health + 15
	if cond_data.data["cur_health"] > player_cond.max_health:
		cond_data.data["cur_health"] = player_cond.max_health
	
	GlobalEvents.emit_signal("onMessageReceived", cond_data)


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
	var item_entity_id = _server_manager.get_new_entity_id()
	
	var visual_data = ComponentData.new()
	visual_data.entity_id = item_entity_id
	visual_data.component_name = VisualComponent.NAME
	visual_data.data["visual"] = "item/%s" % info.visual
	visual_data.data["animation"] = "spawn"
	GlobalEvents.emit_signal("onMessageReceived", visual_data)
	
	# TODO Bestimmung der Player Entity nicht via GlobalData.
	# Position the item to the player position.
	var player = GlobalData.entities.get_entity(GlobalData.client_account_id)
	var player_pos = player.get_component(PositionComponent.NAME)
	var pos_data = ComponentData.new()
	pos_data.entity_id = item_entity_id
	pos_data.component_name = PositionComponent.NAME
	pos_data.data["x"] = player_pos.x
	pos_data.data["y"] = player_pos.y
	pos_data.data["z"] = player_pos.z
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
