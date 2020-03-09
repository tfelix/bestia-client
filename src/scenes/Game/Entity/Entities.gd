extends Node
class_name Entities

const ChatHoverText = preload("res://scenes/GameUI/Chat/ChatHoverText/ChatHoverText.tscn")

var _entities = { }

func _ready():
	GlobalData.entities = self
	GlobalEvents.connect("onEntityAdded", self, "_add_entity")
	GlobalEvents.connect("onEntityRemoved", self, "_add_entity")
	GlobalEvents.connect("onMessageReceived", self, "_server_received")


func free():
	if GlobalData.entities == self:
		GlobalData.entities = null
	.free()


func _server_received(msg) -> void:
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
	var entity = get_entity(msg.entity_id)
	if entity == null:
		print_debug("_display_hover_chat: Entity with id ", msg.entity_id, " not found")
		return
	var chat_text = ChatHoverText.instance()
	entity.add_child(chat_text)
	chat_text.set_text("%s: %s" % [msg.username, msg.text])


func _check_send_player_bestia_update(msg: Component, entity: Entity) -> void:
	if entity == null:
		return
	if msg is PlayerComponent && GlobalData.client_account_id == msg.account_id:
		GlobalEvents.emit_signal("onPlayerEntityUpdated", entity)


func get_entity(id: int) -> Entity:
	if not _entities.has(id):
		printerr("Entity ", id, " was not found")
		return null
	return _entities[id]


func _send_to_entity(msg) -> Entity:
	var e = null
	
	if not _entities.has(msg.entity_id):
		# Check if this is a visual component message so we can create entity.
		if msg is VisualComponent:
			e = _spawn_entity(msg)
		else:
			# Probably we sadly need some kind of caching for some time if
			# a visual component arrives later...
			printerr("Entity ", msg.entity_id, " was not found")
			return null
	else:
		e = _entities[msg.entity_id]
	e.handle_message(msg)
	return e


func _add_entity(entity) -> void:
	print_debug("Added entity ", entity.id)
	_entities[entity.id] = entity


func _remove_entity(entity: Entity) -> void:
	_entities.erase(entity.id)


func _spawn_entity(visual: VisualComponent) -> Entity:
	var apple = load("res://scenes/Game/Entity/Item/Apple/Apple.tscn")
	var new_entity = apple.instance()
	add_child(new_entity)
	return new_entity
	
