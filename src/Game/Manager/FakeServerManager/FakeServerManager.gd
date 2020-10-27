extends Node

var _current_entity_id = 100

# The fake server listens to messages from the game and instead of sending it
# to the server and reacting on the response it will directly manipulate the game
# with predefined actions.
var _env_comp: EnvironmentComponent

onready var _item_handler = $FakeItemHandler
onready var _mob_handler = $FakeMobHandler
onready var _interaction_handler = $FakeInteractionHandler

func _ready():
	GlobalEvents.connect("onMessageSend", self, "_on_message")
	GlobalEvents.connect("onEntityAdded", self, "_setup_entity_id")
	
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


"""
Possibly sets up an entity id if the spawned entity has not yet one.
"""
func _setup_entity_id(entity) -> void:
	if entity.id != 0:
		return
	entity.id = get_new_entity_id()


"""
This is for local demo only. It makes sure all entity ids are unique if they
are not send from a server.
"""
func get_new_entity_id() -> int:
	_current_entity_id += 1
	return _current_entity_id


func _on_message(payload):
	if payload is InteractionRequest:
		_interaction_handler.check_interactions(payload)
	if payload is ChatSend:
		_send_chat(payload)
	elif payload is UseAttackMessage:
		_mob_handler.use_skill(payload)
	elif payload is ItemDropMessage:
		_item_handler.drop_item(payload)
	elif payload is PickupItemRequestMessage:
		_item_handler.pick_item(payload)
	elif payload is RequestInventoryMessage:
		_item_handler.send_items()
	elif payload is ItemUseRequestMessage:
		_item_handler.request_item_use(payload)
	elif payload is ItemUseMessage:
		_item_handler.use_item(payload)
	elif payload is RequestAttackListMessage:
		_send_attacks()
	elif payload is RequestGainPointMessage:
		_send_gainpoints()
	else:
		print_debug("Unknown message: ", payload)
		pass

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


func _send_gainpoints() -> void:
	var msg = GainPointData.new()
	msg.value = 112
	GlobalEvents.emit_signal("onMessageReceived", msg)


func _send_attacks() -> void:
	var response = ResponseAttackListMessage.new()
	response.attacks = [
		{"database_name": "small_fireball", "attack_entity_id": 1, "level": 1}
	]

	GlobalEvents.emit_signal("onMessageReceived", response)


func _send_chat(msg: ChatSend) -> void:
	var response = ChatMessage.new()
	# This is not the entity ID. We must also fetch the username from the player
	response.entity_id = GlobalData.client_account_id
	response.username = "rocket"
	response.text = msg.text
	response.type = msg.type
	GlobalEvents.emit_signal("onMessageReceived", response)


func _chop_tree(tree_entity: Entity):
	var no_movement = NoMovementComponent.new()
	# Some components have a visual clue, others dont
	GlobalData.player.push_back(no_movement)
	# Add Progress Component to player entity
	# After progress is finished despawn tree with animation
	# Remove NoMovement Component
	# Spawn Loot on the Ground
	pass


func _on_OneShot2_timeout():
	var msg = ComponentRemoveMessage.new()
	msg.component_name = PerformConstructionComponent.NAME
	msg.entity_id = 1
	GlobalEvents.emit_signal("onMessageReceived", msg)


func _on_EnvironmentUpdate_timeout():
	var active_comp = ActivePlayerBestiaComponent.new()
	active_comp.entity_id = 1000
	GlobalEvents.emit_signal("onMessageReceived", active_comp)

	_env_comp.current_temp = randi() % 30 - 10
	GlobalEvents.emit_signal("onMessageReceived", _env_comp)
