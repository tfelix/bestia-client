extends Control
class_name ChatHoverText

export(int) var display_time = 10

onready var label = $Text
var _entity: Entity

func _ready() -> void:
	$DestroyTimer.wait_time = display_time
	_entity = get_parent() as Entity
	_remove_other_chat_nodes()
	_update_position()


func free() -> void:
  PubSub.unsubscribe(self)
  .free()


func _process(delta) -> void:
	_update_position()


# Scan parent for other chat nodes and remove them.
func _remove_other_chat_nodes() -> void:
	for node in _entity.get_children():
		# see https://github.com/godotengine/godot/issues/25252
		if node != self && get_class().casecmp_to(node.get_class()) == 0:
			# We must remove ourselfe here or we crash because of PubSub
			PubSub.unsubscribe(node)
			node.queue_free()


func set_text(text):
	label.text = text


func _update_position():
	# TODO Maybe cache this
	var aabb = _entity.get_aabb()
	var camera = get_tree().get_root().get_camera()
	
	var offset = Vector2(label.get_size().x / 2, 0)
	var node_height = aabb.size.y
	var pos = camera.unproject_position(aabb.position + Vector3(0.0, node_height, 0.0)) - offset
	label.set_position(pos)


func _on_DestroyTimer_timeout():
	# We must remove ourselfe here or we crash because of PubSub
	# PubSub.unsubscribe(self)
	queue_free()
