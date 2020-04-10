extends Node
class_name Entities

const ChatHoverText = preload("res://UI/Chat/ChatHoverText/ChatHoverText.tscn")

var _spawner = EntitySpawner.new()
var _entities = { }

func _ready():
	GlobalData.entities = self
	GlobalEvents.connect("onEntityAdded", self, "_add_entity")
	GlobalEvents.connect("onEntityRemoved", self, "_add_entity")
	GlobalEvents.connect("onMessageReceived", self, "_server_received")
	call_deferred("setup_existing_entities")


func free():
	if GlobalData.entities == self:
		GlobalData.entities = null
	.free()


"""
There might be entities pre-setup already. We need to notify other systems
about the existence of these entities. E.g. the player entity.
"""
func setup_existing_entities() -> void:
	for node in get_children():
		var entity_node = node.find_node("Entity")
		if entity_node == null:
			continue
		var pc = entity_node.get_component(PlayerComponent.NAME) as PlayerComponent
		_check_send_player_entity_update(pc, entity_node)


func _server_received(msg) -> void:
	if msg is ComponentData:
		var e = _send_to_entity(msg)
		_check_send_player_entity_update(msg, e)
	if msg is ComponentRemoveMessage:
		_send_to_entity(msg)
	else:
		pass


func _check_send_player_entity_update(msg: Component, entity: Entity) -> void:
	if entity == null:
		return
	if msg is PlayerComponent && GlobalData.client_account_id == msg.account_id:
		GlobalEvents.emit_signal("onPlayerEntityUpdated", entity)


func get_entity(id: int) -> Entity:
	if not _entities.has(id):
		print("Entity ", id, " was not found")
		return null
	return _entities[id]


func _send_to_entity(msg) -> Entity:
	var e = null
	
	if not _entities.has(msg.entity_id):
		# Check if this is a visual component message so we can create entity.
		if msg is VisualComponent:
			e = _spawner.spawn_entity(msg)
			add_child(e)
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
	_entities[entity.id] = entity


func _remove_entity(entity: Entity) -> void:
	_entities.erase(entity.id)
	
