extends Node
class_name Entities

var PST = load("res://PubSubTopics.gd")
var _entities = { }

func _ready():
	PubSub.subscribe(PST.ENTITY_ADDED, self)

func free():
  PubSub.publish(PST.ENTITY_REMOVED, self)
  .free()

func event_published(event_key, payload) -> void:
	match (event_key):
		PST.ENTITY_ADDED:
			_add_entity(payload)
		PST.ENTITY_REMOVED:
			_remove_entity(payload)
	
func _add_entity(entity: Entity):
	_entities[entity.id] = entity
	
func _remove_entity(entity: Entity):
	_entities.erase(entity.id)