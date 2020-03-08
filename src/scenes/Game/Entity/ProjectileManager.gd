extends Node

const Arrow = preload("res://scenes/Game/Projectile/Arrow.tscn")

export(NodePath) var _entites_path
var _entities

func _ready():
	_entities = get_node(_entites_path)
	GlobalEvents.connect("onMessageReceived", self, "_server_received")


func _server_received(msg) -> void:
	if msg is RangedAttackMessage:
		handle_message(msg)
	else:
		pass


func handle_message(msg: RangedAttackMessage) -> void:
	var target_entity = _entities.get_entity(msg.target_id)
	var origin_entity = _entities.get_entity(msg.entity_id)
	var arrow = Arrow.instance()
	target_entity.get_spatial().add_child(arrow)
	arrow.global_transform.origin = origin_entity.get_spatial().global_transform.origin
	arrow.start(target_entity)
