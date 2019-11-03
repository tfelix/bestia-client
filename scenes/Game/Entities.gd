extends Node
class_name Entities

var _entities = { }

# This is for testing
onready var _entity_1 = $TestMob

func _ready():
	PubSub.subscribe(PST.ENTITY_ADDED, self)
	PubSub.subscribe(PST.ENTITY_REMOVED, self)
	PubSub.subscribe(PST.SERVER_SEND, self)


func free():
  PubSub.unsubscribe(self)
  .free()


func event_published(event_key, payload) -> void:
	match (event_key):
		PST.ENTITY_ADDED:
			_add_entity(payload)
		PST.ENTITY_REMOVED:
			_remove_entity(payload)
		PST.SERVER_SEND:
			_server_send(payload)


func _server_send(msg) -> void:
	if msg is DamageMessage:
		_send_to_entity(msg)
	else:
		pass


func _send_to_entity(msg) -> void:
	if msg.target_entity == 1:
		_entity_1.handle_message(msg)
	# var e = _entities[msg.target_entity]
	# if e != null:
		


func _add_entity(entity: Entity) -> void:
	_entities[entity.id] = entity


func _remove_entity(entity: Entity) -> void:
	_entities.erase(entity.id)