extends Control
class_name ChatHoverText

export(int) var display_time = 10
export(Vector2) var offset = Vector2(0, -60)

onready var label = $Text
var _entity: Entity

func _ready() -> void:
	$DestroyTimer.wait_time = display_time
	_entity = get_parent() as Entity
	_remove_other_chat_nodes()


func get_class() -> String:
	return "ChatHoverText"


func _process(delta) -> void:
	_update_position()


# Scan parent for other chat nodes and remove them.
func _remove_other_chat_nodes() -> void:
	for node in _entity.get_children():
		# see https://github.com/godotengine/godot/issues/25252
		if node != self && node.get_class() == "ChatHoverText":
			node.queue_free()


func set_text(text):
	label.text = text


func _update_position():
	var camera = get_tree().get_root().get_camera()
	# Camera might be null if we get it too early
	if camera == null:
		return
	
	var aabb = _entity.get_aabb()
	var entity_pos = _entity.get_spatial().global_transform.origin
	var node_height = aabb.size.z
	entity_pos.y += node_height
	var cam_pos = camera.unproject_position(entity_pos)
	var new_pos = Vector2(cam_pos.x - label.get_size().x / 2 + offset.x, cam_pos.y + offset.y)
	label.set_position(new_pos)


func _on_DestroyTimer_timeout():
	queue_free()
