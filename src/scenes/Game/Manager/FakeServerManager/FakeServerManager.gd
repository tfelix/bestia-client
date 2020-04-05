extends Node

# The fake server listens to messages from the game and instead of sending it
# to the server and reacting on the response it will directly manipulate the game
# with predefined actions.
const NoMovementComponent = preload("res://scenes/Game/Entity/Component/NoMovementComponent.gd")
const ConstructionComponent = preload("res://scenes/Game/Entity/Component/PerformConstructionComponent.gd")

onready var cast_timer = $CastTimer

export var player_entity_id = 1000

var _env_comp: EnvironmentComponent
var _casted_entity_id: int = 0
var _item_handler = FakeItemHandler.new()

func _ready():
	GlobalEvents.connect("onMessageSend", self, "_on_message")
	
	# We must wait until the scene is setup in order to call this.
	call_deferred("_setup_account")

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

	_item_handler.setup()


func _on_message(payload):
	if payload is ChatSend:
		_send_chat(payload)
	elif payload is UseAttackMessage:
		_use_skill(payload)
	elif payload is ItemDropMessage:
		_item_handler.drop_item(payload)
	elif payload is RequestInventoryMessage:
		_item_handler.send_items()
	elif payload is ItemUseRequestMessage:
		_respond_item_use(payload)
	elif payload is ItemUseMessage:
		_item_handler.use_item(payload)
	elif payload is RequestAttackListMessage:
		_send_attacks()
	else:
		print_debug("Unknown message: ", payload)
		pass


func _respond_item_use(msg: ItemUseRequestMessage):
	var response = ItemUseResponseMessage.new()
	# TODO Build a proper test for the items found in the demo
	response.can_use = true
	response.player_item_id = msg.player_item_id
	response.request_id = msg.request_id
	GlobalEvents.emit_signal("onMessageReceived", response)


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


func _send_attacks() -> void:
	var atk1 = Attack.new()
	atk1.attack_entity_id = 1
	atk1.attack_id = 1
	atk1.db_name = "TACKLE"
	atk1.element = "NORMAL"
	atk1.mana = 2
	atk1.level = 1

	var atk2 = Attack.new()
	atk2.attack_entity_id = 1
	atk2.attack_id = 2
	atk2.db_name = "SMALL_FIREBALL"
	atk2.element = "FIRE"
	atk2.mana = 5
	atk2.level = 2
	
	var atk3 = Attack.new()
	atk3.attack_entity_id = 1
	atk3.attack_id = 3
	atk3.db_name = "SMALL_HEAL"
	atk3.element = "HOLY"
	atk3.mana = 10
	atk3.level = 5

	var response = ResponseAttackListMessage.new()
	response.attacks = [atk1, atk2, atk3]

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
		dmg_msg.total_damage = randi() % 20 + 10
		
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
		cast_comp.entity_id = player_entity_id
		cast_comp.target_entity_id = msg.target_entity
		GlobalEvents.emit_signal("onMessageReceived", cast_comp)
	
		# Setup the damage display later on
		_casted_entity_id = msg.target_entity
		cast_timer.start(cast_comp.cast_time / 1000.0)


func _on_CastTimer_timeout():
	var cast_remove = ComponentRemoveMessage.new()
	cast_remove.component_name = CastComponent.NAME
	cast_remove.entity_id = player_entity_id
	GlobalEvents.emit_signal("onMessageReceived", cast_remove)

	var dmg_msg = DamageMessage.new()
	dmg_msg.entity_id = _casted_entity_id
	dmg_msg.total_damage = randi() % 20 + 30

	var fx_msg = FxMessage.new()
	fx_msg.target_id = _casted_entity_id
	fx_msg.fx = "fireball"
	fx_msg.damage = dmg_msg
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
