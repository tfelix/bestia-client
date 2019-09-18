extends Control
class_name ChatHoverText

export(int) var display_time = 10

var _entity: Entity

func _ready() -> void:
	PubSub.subscribe(PST.CLIENT_CAM_CHANGED, self)
	$DestroyTimer.wait_time = display_time
	get_tree().get_root().connect("size_changed", self, "_update_position")
	_entity = get_parent() as Entity
	_remove_other_chat_nodes()
	_update_position()


func free() -> void:
  PubSub.unsubscribe(self)
  .free()


func event_published(event_key, payload) -> void:
  match (event_key):
    PST.CLIENT_CAM_CHANGED:
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
	$Text.text = text

func _update_position():
	var aabb = _entity.get_aabb()
	var label = $Text
	var camera = get_tree().get_root().get_camera()
	
	var offset = Vector2(label.get_size().x / 2, 0)
	var node_height = aabb.size.y
	var pos = camera.unproject_position(aabb.position + Vector3(0.0, node_height, 0.0)) - offset
	label.set_position(pos)

func _on_DestroyTimer_timeout():
	# We must remove ourselfe here or we crash because of PubSub
	PubSub.unsubscribe(self)
	queue_free()
