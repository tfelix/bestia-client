extends Node

export(NodePath) var _entites_path
var _entities

var _effects = {}

func _ready():
	_entities = get_node(_entites_path)
	GlobalEvents.connect("onMessageReceived", self, "_server_received")


func _server_received(msg) -> void:
	if msg is FxMessage:
		_handle_message(msg)
	else:
		pass


func _handle_message(msg: FxMessage) -> void:
	var target_entity = _entities.get_entity(msg.target_id)
	var origin_entity = _entities.get_entity(msg.entity_id)
	if target_entity == null:
		printerr("Entity ", msg.entity_id, " not found")
		return
	if not _effects.has(msg.fx):
		var fx_path = _get_fx_path(msg.fx_type, msg.fx)
		_effects[msg.fx] = load(fx_path)
	
	var fx = _effects[msg.fx].instance()
	target_entity.get_spatial().add_child(fx)
	fx.start(target_entity, msg.damage)


func _get_fx_path(fx_type: String, name: String) -> String:
	# Possible add other fx paths here if needed
	name = name.capitalize()
	return "res://scenes/Attack/%s/%s.tscn" % [name, name]
