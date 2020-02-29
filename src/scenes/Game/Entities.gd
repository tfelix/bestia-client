extends Node
class_name Entities

var _entities = { }
var _player_entity: Entity = null

func _ready():
	GlobalData.entities = self
	GlobalEvents.connect("onEntityAdded", self, "_add_entity")
	GlobalEvents.connect("onEntityRemoved", self, "_add_entity")
	GlobalEvents.connect("onReceiveFromServer", self, "_server_received")


func free():
	if GlobalData.entities == self:
		GlobalData.entities = null
	.free()


# Returns the current player entity
func get_player_entity() -> Entity:
	return _player_entity


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
	if msg is ChatMessage:
		_display_hover_chat(msg)
	else:
		pass


func _display_hover_chat(msg: ChatMessage) -> void:
	if entity != null:
		var chat_text = HoverChatText.instance()
		entity.add_child(chat_text)
		chat_text.set_text(msg.text)
	else:
		print_debug("_display_hover_chat: Entity with id ", msg.entity_id, " not found")


func _check_send_player_bestia_update(msg: Component, entity: Entity) -> void:
	if entity == null:
		return
	if msg is ActivePlayerBestiaComponent:
		var new_player = get_entity(msg.entity_id)
		_player_entity = new_player
	if msg is PlayerComponent && GlobalData.client_account_id == msg.account_id:
		GlobalEvents.emit_signal("onPlayerEntityUpdated", entity)


func get_entity(id: int) -> Entity:
	if not _entities.has(id):
		printerr("Entity ", id, " was not found")
		return null
	return _entities[id]


func _send_to_entity(msg) -> Entity:
	if not _entities.has(msg.entity_id):
		printerr("Entity ", msg.entity_id, " was not found")
		return null
	var e = _entities[msg.entity_id]
	e.handle_message(msg)
	return e


func _add_entity(entity: Entity) -> void:
	print_debug("Added entity ", entity.id)
	_entities[entity.id] = entity


func _remove_entity(entity: Entity) -> void:
	if entity == _player_entity:
		_player_entity = null
	_entities.erase(entity.id)
