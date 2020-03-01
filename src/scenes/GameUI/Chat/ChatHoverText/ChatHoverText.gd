extends Control
class_name ChatHoverText

export(int) var display_time = 10

onready var label = $Text
var _entity: Spatial

func _ready() -> void:
	$DestroyTimer.wait_time = display_time
	_entity = get_parent() as Spatial
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
	var aabb = _entity.get_aabb()
	var entity_pos = _entity.global_transform.origin
	var camera = get_tree().get_root().get_camera()
	# Camera might be null if we get 
	if camera == null:
		return
	
	var offset = Vector2(label.get_size().x / 2, 0)
	var node_height = aabb.size.y
	var pos = camera.unproject_position(entity_pos + Vector3(0.0, node_height, 0.0)) - offset
	label.set_position(pos)


func _on_DestroyTimer_timeout():
	queue_free()
