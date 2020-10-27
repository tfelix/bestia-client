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
	yield(owner, "ready")
	setup_existing_entities()


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
	if msg is EntityRemoveMessage:
		_send_to_entity(msg)
	else:
		pass


func _check_send_player_entity_update(msg: ComponentData, entity: Entity) -> void:
	if entity == null:
		return
	# We need a proper way to update components. Currently its a mess and the ComponentData
	# does not have a account_id. It only has the entity id of the player character. But there
	# is no good setup/flow to keep track of the current player entity id.
	#if GlobalData.client_account_id == msg.account_id:
	#	GlobalEvents.emit_signal("onPlayerEntityUpdated", entity)


func get_entity(id: int) -> Entity:
	if not _entities.has(id):
		print("Entity ", id, " was not found")
		return null
	return _entities[id]


func _send_to_entity(msg) -> Entity:
	var e = null
	
	# TODO Improve this code flow
	if not _entities.has(msg.entity_id):
		# Check if this is a visual component message so we can create entity.
		if msg is ComponentData && msg.component_name == VisualComponent.NAME:
			e = _spawner.spawn_entity(msg.data["visual"])
			assert(e != null)
			add_child(e)
			_entities[msg.entity_id] = e
		else:
			# Probably we sadly need some kind of caching for some time if
			# a visual component arrives later...
			printerr("Entity ", msg.entity_id, " was not found")
			return null
	else:
		e = _entities[msg.entity_id]
	# TODO Improve this toplevel call as this is not on the entity itself but rather
	# on the spawned node. Solve this better. 
	e.handle_message(msg)
	return e


func _add_entity(entity) -> void:
	_entities[entity.id] = entity


func _remove_entity(entity_id: int) -> void:
	_entities.erase(entity_id)
	
