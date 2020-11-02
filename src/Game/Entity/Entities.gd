extends Node
class_name Entities

const ChatHoverText = preload("res://UI/Chat/ChatHoverText/ChatHoverText.tscn")

var _spawner = EntitySpawner.new()
var _entities = { }

# Some entities might receive out of order messages
# so we need to buffer their messages until a visual component
# arrives and we can spawn them.
var _entities_without_visual = { }

func _ready():
	GlobalEvents.connect("onEntityAdded", self, "_add_entity")
	GlobalEvents.connect("onEntityRemoved", self, "_add_entity")
	GlobalEvents.connect("onMessageReceived", self, "_server_received")


func free():
	if GlobalData.entities == self:
		GlobalData.entities = null
	.free()


func _server_received(msg) -> void:	
	if msg is ComponentRemoveMessage:
		var entity = get_entity(msg.entity_id)
		if entity == null:
			return
		entity.remove_component(msg.component_name)
	elif msg is EntityRemoveMessage:
		var entity = get_entity(msg.entity_id)
		if entity == null:
			return
		entity.remove()
		_entities.erase(msg.entity_id)
	elif "entity_id" in msg:
		var entity = get_entity(msg.entity_id)
		if entity == null:
			# Handle this
			#_try_spawn_entity(msg)
			pass
		else:
			entity.update_component(msg)


func get_entity(id: int) -> Entity:
	if not _entities.has(id):
		print("Entity ", id, " was not found")
		return null
	return _entities[id]


func _try_spawn_entity(message) -> Entity:
	if message is VisualComponent:
		var e = _spawner.spawn_entity(message.visual)
		assert(e != null)
		_entities[message.entity_id] = e
		return e
	
	return null


func _add_entity(entity) -> void:
	_entities[entity.id] = entity


func _remove_entity(entity_id: int) -> void:
	_entities.erase(entity_id)
	
