extends Node
"""
Responds to the players request to handle interactions with
certain entities.
"""
class_name FakeInteractionHandler

var _entities = {}
var _player_entity: Entity

func _ready():
	GlobalEvents.connect("onEntityAdded", self, "_register_entity")
	GlobalEvents.connect("onEntityRemoved", self, "_remove_entity")
	GlobalEvents.connect("player_entity_updated", self, "_player_updated")


func _player_updated(player_entity: Entity, component) -> void:
	_player_entity = player_entity


func check_interactions(msg: InteractionRequest) -> void:
	if not _entities.has(msg.entity_id):
		printerr("check_interactions: Entity %s was not found" % msg.entity_id)
		#return
	
	# TODO for testing
	var cast_comp = CastComponent.new()
	cast_comp.cast_time_ms = 4000
	cast_comp.cast_db_name = "wood_chop"
	cast_comp.target_entity_id = msg.entity_id
	cast_comp.entity_id = _player_entity.id
	GlobalEvents.emit_signal("onMessageReceived", cast_comp)
	

func _get_interactions(visual: String) -> Array:
	match visual:
		"wooden_bed":
			return ["use"]
		_:
			return []


func _register_spawned_item(entity: Entity) -> void:
	# This is a crude hack and wont work if entity is not added
	# directly under the root object (which is usually the case)
	if not entity.get_parent() is Tree01:
		return
	_entities[entity.id] = entity


func _remove_spawned_item(entity: Entity) -> void:
	_entities.erase(entity.id)
