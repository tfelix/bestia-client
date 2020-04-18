extends Node

const Arrow = preload("res://Game/Projectile/Arrow.tscn")

export(NodePath) var _entites_path
var _entities

func _ready():
	_entities = get_node(_entites_path)
	GlobalEvents.connect("onMessageReceived", self, "_server_received")


func _server_received(msg) -> void:
	if msg is RangedAttackMessage:
		handle_message(msg)
	else:
		return


func handle_message(msg) -> void:
	var target_entity = _entities.get_entity(msg.target_id) as Entity
	var origin_entity = _entities.get_entity(msg.entity_id) as Entity
	var arrow = Arrow.instance()
	
	add_child(arrow)
	
	var spawn_pos = origin_entity.get_spatial().global_transform.origin
	var y_offset = origin_entity.get_aabb().size.y / 0.75
	spawn_pos.y += y_offset
	arrow.start(spawn_pos, target_entity, msg.damage)

