extends Node
class_name Entities

var _entities = { }

# This is for testing
onready var _entity_2 = $TestMob
onready var _player = $Player

func _ready():
	Global.entities = self
	PubSub.subscribe(PST.ENTITY_ADDED, self)
	PubSub.subscribe(PST.ENTITY_REMOVED, self)
	PubSub.subscribe(PST.SERVER_RECEIVE, self)


func free():
	if Global.entities == self:
		Global.entities = null
	PubSub.unsubscribe(self)
	.free()


# Returns the current player entity
func get_player_entity() -> Entity:
	# In the future it will have to detect incoming component messages
	# in order to setup the player entity correctly.
	return _player


func event_published(event_key, payload) -> void:
	match (event_key):
		PST.ENTITY_ADDED:
			_add_entity(payload)
		PST.ENTITY_REMOVED:
			_remove_entity(payload)
		PST.SERVER_RECEIVE:
			_server_received(payload)


func _server_received(msg) -> void:
	if msg is DamageMessage:
		_send_to_entity(msg)
	if msg is FxMessage:
		_send_to_entity(msg)
	if msg is Component:
		var e = _send_to_entity(msg)
		_check_send_player_bestia_update(msg, e)
	if msg is ComponentRemoveMessage:
		_send_to_entity(msg)
	else:
		pass


func _check_send_player_bestia_update(msg: Component, entity: Entity) -> void:
	if entity == null:
		return
	if msg is ActivePlayerBestiaComponent:
		var new_player = get_entity(msg.entity_id)
		_player = new_player
	if msg is PlayerComponent && Global.client_account == msg.account_id:
		PubSub.publish(PST.ENTITY_PLAYER_UPDATED, entity)


func get_entity(id: int) -> Entity:
	# Remove if testing is finished
	if id == 1:
		return _player
	if id == 2:
		return _entity_2
	
	return _entities[id]


func _send_to_entity(msg) -> Entity:
	if msg.entity_id == 1:
		_player.handle_message(msg)
		return _player
	if msg.entity_id == 2:
		_entity_2.handle_message(msg)
		return _entity_2
	var e = _entities[msg.entity_id]
	if e != null:
		e.handle_message(msg)
		return e
	print_debug("Server send message for unknown entity: ", msg.entity_id)
	return null


func _add_entity(entity: Entity) -> void:
	_entities[entity.id] = entity


func _remove_entity(entity: Entity) -> void:
	if entity == _player:
		_player = null
	_entities.erase(entity.id)
