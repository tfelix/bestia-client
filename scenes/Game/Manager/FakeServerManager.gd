extends Node

# The fake server listens to messages from the game and instead of sending it
# to the server and reacting on the response it will directly manipulate the game
# with predefined actions.

var NoMovementComponent = preload("res://scenes/Game/Entity/Component/NoMovementComponent/NoMovementComponent.gd")
var UseSkillMessage = preload("res://scenes/GameUI/shortcuts/UseSkillMessage.gd")

var _player_items = []

func _ready():
	PubSub.subscribe(PST.SERVER_SEND, self)

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
			else:
				pass
				# _chop_tree(payload)

func _send_chat(msg: ChatSend) -> void:
	print_debug("Received chat msg: ", msg)
	var response = ChatMessage.new()
	response.entity_id = 0
	response.username = "rocket"
	response.text = msg.text
	response.type = msg.type
	PubSub.publish(PST.CHAT_RECEIVED, response)


func _setup_items() -> void:
	var item1 = ItemModel.new()
	item1.database_name = "empty_bottle"
	item1.weight = 1
	item1.amount = 1
	item1.type = ItemModel.ItemType.ETC
	_player_items.append(item1)
	var item2 = ItemModel.new()
	item2.database_name = "knife"
	item2.weight = 5
	item2.amount = 3
	item2.type = ItemModel.ItemType.ETC
	_player_items.append(item2)
	var item3 = ItemModel.new()
	item3.database_name = "simple_axe"
	item3.weight = 10
	item3.amount = 1
	item3.type = ItemModel.ItemType.EQUIP
	_player_items.append(item3)
	
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