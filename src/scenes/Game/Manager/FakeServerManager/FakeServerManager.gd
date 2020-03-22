extends Node

# The fake server listens to messages from the game and instead of sending it
# to the server and reacting on the response it will directly manipulate the game
# with predefined actions.

const NoMovementComponent = preload("res://scenes/Game/Entity/Component/NoMovementComponent.gd")
const ConstructionComponent = preload("res://scenes/Game/Entity/Component/PerformConstructionComponent.gd")

onready var cast_timer = $CastTimer

export var player_entity_id = 1000

var _player_items = []

var _env_comp: EnvironmentComponent
var _casted_entity_id: int = 0

func _ready():
	GlobalEvents.connect("onMessageSend", self, "_on_message")
	
	# We must wait until the scene is setup in order to call this.
	call_deferred("_setup_account")
	call_deferred("_setup_items")

	_env_comp = EnvironmentComponent.new()
	_env_comp.entity_id = 1000
	_env_comp.rain_intensity = 0 # 0: no rain, 10: little rain, 50 moderate rain, 100+ storm, heavy rain
	_env_comp.light_intensity = 70 # 0: total darkness, 20: moonshine, 70-80: normal day, 100+ bright summer day
	_env_comp.wind = Vector2(3, 1)
	_env_comp.max_tolerable_temp = 46
	_env_comp.min_tolerable_temp = -10
	_env_comp.current_temp = 15
	_env_comp.sunrise = 0.20 # The usual sunrise is at 0.2
	_env_comp.sunset = 0.70 # The usual sunset is at 0.7
	_env_comp.day_progress = 1 # 0 Start of Day (00:00), 1 End of Day (23:59)


func _on_message(payload):
	if payload is ChatSend:
		_send_chat(payload)
	elif payload is UseAttackMessage:
		_use_skill(payload)
	elif payload is ItemDropMessage:
		_drop_item(payload)
	elif payload is RequestInventoryMessage:
		_send_items()
	elif payload is RequestAttackListMessage:
		_send_attacks()
	elif payload is ItemUseRequestMessage:
		_respond_item_use(payload)
	elif payload is ItemUseMessage:
		_use_item(payload)
	else:
		print_debug("Unknown message: ", payload)
		pass


func _respond_item_use(msg: ItemUseRequestMessage):
	var response = ItemUseResponseMessage.new()
	response.can_use = true
	response.player_item_id = msg.player_item_id
	response.request_id = msg.request_id
	GlobalEvents.emit_signal("onMessageReceived", response)


func _get_player_item(player_item_id) -> ItemModel:
	for item in _player_items:
		if item.player_item_id  == player_item_id:
			return item
	return null


func _remove_player_item(player_item: ItemModel) -> void:
	_player_items.erase(player_item)
	_send_items()


func _use_item(msg: ItemUseMessage) -> void:
	var player_item = _get_player_item(msg.player_item_id)
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


func _setup_account() -> void:
	var info = AccountInfoMessage.new()
	info.account_id = 1
	GlobalEvents.emit_signal("onMessageReceived", info)
	
	var player = PlayerComponent.new()
	player.entity_id = 1000
	player.id = 1
	player.player_bestia_id = 1
	player.player_name = "rocket"
	GlobalEvents.emit_signal("onMessageReceived", player)


func _setup_items() -> void:
	var item1 = ItemModel.new()
	item1.item_id = 1
	item1.player_item_id = 1
	item1.amount = 1
	_player_items.append(item1)
	var item2 = ItemModel.new()
	item2.item_id = 2
	item2.player_item_id = 2
	item2.amount = 3
	_player_items.append(item2)
	var item3 = ItemModel.new()
	item3.item_id = 3
	item3.player_item_id = 3
	item3.amount = 1
	_player_items.append(item3)
	var item4 = ItemModel.new()
	item4.item_id = 4
	item4.player_item_id = 4
	item4.amount = 1
	_player_items.append(item4)
	var item5 = ItemModel.new()
	item5.item_id = 5
	item5.player_item_id = 5
	item5.amount = 5
	_player_items.append(item5)


func _send_items() -> void:
	var update_msg = InventoryUpdateMessage.new()
	update_msg.items = _player_items
	update_msg.max_items = 200
	update_msg.max_weight = 500
	GlobalEvents.emit_signal("onMessageReceived", update_msg)


func _drop_item(msg: ItemDropMessage) -> void:
	if msg.item.player_item_id == 5:
		var item = _get_player_item(msg.item.player_item_id)
		if item == null:
			return
		item.amount -= msg.amount
		if item.amount <= 0:
			_remove_player_item(item)
		_send_items()
		var visual_comp = VisualComponent.new()
		visual_comp.entity_id = 8888
		visual_comp.entity_id = 8888
		visual_comp.visual = "apple"
		visual_comp.type = "item"
		visual_comp.animation = "spawn"
		GlobalEvents.emit_signal("onMessageReceived", visual_comp)

func _send_attacks() -> void:
	var atk1 = Attack.new()
	atk1.attack_entity_id = 1
	atk1.attack_id = 1
	atk1.db_name = "tackle"
	atk1.element = "NORMAL"
	atk1.mana = 2
	atk1.level = 1

	var atk2 = Attack.new()
	atk2.attack_entity_id = 1
	atk2.attack_id = 2
	atk2.db_name = "fireball"
	atk2.element = "FIRE"
	atk2.mana = 5
	atk2.level = 2

	var response = ResponseAttackListMessage.new()
	response.attacks = [atk1, atk2]

	GlobalEvents.emit_signal("onMessageReceived", response)



func _send_chat(msg: ChatSend) -> void:
	var response = ChatMessage.new()
	response.entity_id = 1000 #GlobalData.client_account_id
	response.username = "rocket"
	response.text = msg.text
	response.type = msg.type
	GlobalEvents.emit_signal("onMessageReceived", response)


func _use_skill(msg: UseAttackMessage):
	if msg.player_attack_id == UseAttackMessage.RANGE_ATTACK_ID:
		var dmg_msg = DamageMessage.new()
		dmg_msg.entity_id = msg.target_entity
		dmg_msg.total_damage = randi() % 100 + 1
		
		var ranged_msg = RangedAttackMessage.new()
		ranged_msg.entity_id = player_entity_id
		ranged_msg.target_id = msg.target_entity
		ranged_msg.projectile = "arrow"
		ranged_msg.damage = dmg_msg
		ranged_msg.latency_ms = 10
		
		GlobalEvents.emit_signal("onMessageReceived", ranged_msg)
		
	elif msg.player_attack_id == UseAttackMessage.MELEE_ATTACK_ID:
		# check if distance is ok and then let the attack be made
		print_debug("melee")
	else:
		# Cast the skill
		var cast_comp = CastComponent.new()
		cast_comp.cast_time = 400
		cast_comp.cast_db_name = "skill_fireball"
		cast_comp.entity_id = 1000
		cast_comp.target_entity_id = msg.target_entity
		GlobalEvents.emit_signal("onMessageReceived", cast_comp)
	
		_casted_entity_id = msg.target_entity
	
		cast_timer.start(cast_comp.cast_time / 1000.0)


func _on_CastTimer_timeout():
	var cast_remove = ComponentRemoveMessage.new()
	cast_remove.component_name = CastComponent.NAME
	cast_remove.entity_id = 1000
	GlobalEvents.emit_signal("onMessageReceived", cast_remove)

	var dmg_msg = DamageMessage.new()
	# TODO Fix entity ids.
	dmg_msg.entity_id = 2 #_casted_entity_id
	dmg_msg.total_damage = randi() % 100 + 1
	GlobalEvents.emit_signal("onMessageReceived", dmg_msg)

	var fx_msg = FxMessage.new()
	# TODO Fix entity ids.
	fx_msg.entity_id = 2 # _casted_entity_id
	fx_msg.fx = "fireball"
	fx_msg.latency_ms = 10
	GlobalEvents.emit_signal("onMessageReceived", fx_msg)


func _chop_tree(entity: Entity):
	var no_movement = NoMovementComponent.new()
	# Some components have a visual clue, others dont
	GlobalData.player.push_back(no_movement)
	# Add Progress Component to player entity
	# After progress is finished despawn tree
	# Remove NoMovement Component
	# Spawn Loot on the Ground
	pass


func _on_OneShot2_timeout():
	var msg = ComponentRemoveMessage.new()
	msg.component_name = ConstructionComponent.NAME
	msg.entity_id = 1
	GlobalEvents.emit_signal("onMessageReceived", msg)


func _on_EnvironmentUpdate_timeout():
	var active_comp = ActivePlayerBestiaComponent.new()
	active_comp.entity_id = 1000
	GlobalEvents.emit_signal("onMessageReceived", active_comp)

	_env_comp.current_temp = randi() % 30 - 10
	GlobalEvents.emit_signal("onMessageReceived", _env_comp)
