extends Node

const Damage3D = preload("res://UI/Damage/Damage3D.tscn")

export(NodePath) var _entites_path
var _entities

func _ready():
	_entities = get_node(_entites_path)
	GlobalEvents.connect("onMessageReceived", self, "_server_received")
	GlobalEvents.connect("onDamageReceived", self, "handle_message")


func _server_received(msg) -> void:
	if msg is DamageMessage:
		handle_message(msg)
	else:
		pass


func _projectile_hit(target: Entity, msg: DamageMessage) -> void:
	handle_message(msg)


func handle_message(msg: DamageMessage) -> void:
	var entity = _entities.get_entity(msg.entity_id)
	if entity == null:
		print_debug("Entity ", msg.entity_id, " for DamageMessage not found")
		return
	var dmg3d = Damage3D.instance()
	dmg3d.init(msg, entity)
	entity.get_spatial().add_child(dmg3d)
