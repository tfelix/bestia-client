extends Node

# The fake server listens to messages from the game and instead of sending it
# to the server and reacting on the response it will directly manipulate the game
# with predefined actions.

const NoMovementComponent = preload("res://scenes/Game/Entity/Component/NoMovementComponent.gd")
const UseSkillMessage = preload("res://scenes/GameUI/shortcuts/UseSkillMessage.gd")
const ConstructionComponent = preload("res://scenes/Game/Entity/Component/PerformConstructionComponent.gd")

var _player_items = []

var _env_comp: EnvironmentComponent

func _ready():
	PubSub.subscribe(PST.SERVER_SEND, self)
	
	_env_comp = EnvironmentComponent.new()
	_env_comp.entity_id = 1
	_env_comp.rain_intensity = 0 # 0: no rain, 10: little rain, 50 moderate rain, 100+ storm, heavy rain
	_env_comp.light_intensity = 70 # 0: total darkness, 20: moonshine, 70-80: normal day, 100+ bright summer day
	_env_comp.wind = Vector2(3, 1)
	_env_comp.max_tolerable_temp = 46
	_env_comp.min_tolerable_temp = -10
	_env_comp.current_temp = 15
	_env_comp.sunrise = 0.20 # The usual sunrise is at 0.2
	_env_comp.sunset = 0.70 # The usual sunset is at 0.7
	_env_comp.day_progress = 1 # 0 Start of Day (00:00), 1 End of Day (23:59)

func free():
  PubSub.unsubscribe(self)
  .free()

func event_published(event_key, payload):
	match (event_key):
		PST.SERVER_SEND:
			if payload is ChatSend:
				_send_chat(payload)
			if payload is UseSkillMessage:
				_use_skill(payload)
			if payload is ItemDropMessage:
				_send_chat(payload)
			if payload is RequestInventoryMessage:
				_send_items()
			if payload is ItemUseRequestMessage:
				_respond_item_use(payload)
			if payload is ItemUseMessage:
				_use_item(payload)
			else:
				pass
				# _chop_tree(payload)


func _respond_item_use(msg: ItemUseRequestMessage):
	var response = ItemUseResponseMessage.new()
	response.can_use = true
	response.player_item_id = msg.player_item_id
	response.request_id = msg.request_id
	PubSub.publish(PST.INVENTORY_ITEM_USE_RESPONSE, response)


func _use_item(msg: ItemUseMessage) -> void:
	var player_item = null
	for item in _player_items:
		item.player_item_id  == msg.player_item_id
		player_item = item
	if player_item == null:
		return
		
	player_item.amount -= 1
	if player_item.amount <= 0:
		# Remove the item from the array
		pass
	
	if msg.player_item_id == 5:
		# Heal the player
		print_debug("server: player used apple")

	_send_items()


func _send_chat(msg: ChatSend) -> void:
	print_debug("Received chat msg: ", msg)
	var response = ChatMessage.new()
	response.entity_id = Global.client_account
	response.username = "rocket"
	response.text = msg.text
	response.type = msg.type
	PubSub.publish(PST.CHAT_RECEIVED, response)


func _send_items() -> void:
	var item1 = ItemModel.new()
	item1.database_name = "empty_bottle"
	item1.player_item_id = 1
	item1.weight = 1
	item1.amount = 1
	item1.type = ItemModel.ItemType.ETC
	_player_items.append(item1)
	var item2 = ItemModel.new()
	item2.database_name = "knife"
	item2.player_item_id = 2
	item2.weight = 5
	item2.amount = 3
	item2.type = ItemModel.ItemType.ETC
	_player_items.append(item2)
	var item3 = ItemModel.new()
	item3.database_name = "simple_axe"
	item3.player_item_id = 3
	item3.weight = 10
	item3.amount = 1
	item3.type = ItemModel.ItemType.EQUIP
	_player_items.append(item3)
	var item4 = ItemModel.new()
	item4.database_name = "sign_small"
	item4.player_item_id = 4
	item4.weight = 10
	item4.amount = 1
	item4.type = ItemModel.ItemType.STRUCTURE
	_player_items.append(item4)
	var item5 = ItemModel.new()
	item5.database_name = "apple"
	item5.player_item_id = 5
	item5.weight = 1
	item5.amount = 5
	item5.type = ItemModel.ItemType.CONSUMEABLE
	_player_items.append(item5)
	
	var update_msg = InventoryUpdateMessage.new()
	update_msg.items = _player_items
	update_msg.max_items = 200
	update_msg.max_weight = 500
	PubSub.publish(PST.INVENTORY_UPDATE, update_msg)

func _drop_item(msg: ItemDropMessage) -> void:
	print_debug("item drop: ", msg.item.database_name, " amount: ", msg.item.amount)
	pass

func _use_skill(msg):
	print_debug("skill was used: ", msg.skill_db_name)
	pass

func _chop_tree(entity: Entity):
	var no_movement = NoMovementComponent.new()
	# Some components have a visual clue, others dont
	Global.player.push_back(no_movement)
	# Add Progress Component to player entity
	# After progress is finished despawn tree
	# Remove NoMovement Component
	# Spawn Loot on the Ground
	pass

func _on_Timer_timeout():
	
	pass # Replace with function body.


func _on_DamageTimer_timeout():
	var msg = DamageMessage.new()
	msg.entity_id = 1
	msg.total_damage = randi() % 200
	PubSub.publish(PST.SERVER_SEND, msg)


func _on_OneShot_timeout():
	var msg = ConstructionComponent.new()
	msg.label = "Sign Small"
	msg.duration_ms = 3000
	msg.progress_ms = 0
	msg.entity_id = 1
	PubSub.publish(PST.SERVER_RECEIVE, msg)


func _on_OneShot2_timeout():
	var msg = ComponentRemoveMessage.new()
	msg.component_name = ConstructionComponent.NAME
	msg.entity_id = 1
	PubSub.publish(PST.SERVER_RECEIVE, msg)


func _on_EnvironmentUpdate_timeout():
	_env_comp.current_temp = randi() % 30 - 10
	PubSub.publish(PST.SERVER_RECEIVE, _env_comp)
