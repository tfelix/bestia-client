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
	if msg is Component:
		_send_to_entity(msg)
		_check_component_selects_player(msg)
	if msg is ComponentRemoveMessage:
		_send_to_entity(msg)
	else:
		pass


func _check_component_selects_player(msg: Component):
	if msg is ActivePlayerBestiaComponent && Global.client_account == msg.account_id:
		var new_player = get_entity(msg.entity_id)
		_player = new_player


func get_entity(id: int) -> Entity:
	# Remove if testing is finished
	if id == 1:
		return _player
	if id == 2:
		return _entity_2
	
	for e in _entities:
		if e.id == id:
			return e
	return null


func _send_to_entity(msg) -> void:
	if msg.entity_id == 1:
		_player.handle_message(msg)
		return
	if msg.entity_id == 2:
		_entity_2.handle_message(msg)
		return
	var e = _entities[msg.target_entity]
	if e != null:
		e.handle_message(msg)
		return
	print_debug("Server send message for unknown entity: ", msg.entity_id)


func _add_entity(entity: Entity) -> void:
	_entities[entity.id] = entity


func _remove_entity(entity: Entity) -> void:
	if entity == _player:
		_player = null
	_entities.erase(entity.id)