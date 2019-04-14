extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_position()
	get_tree().get_root().connect("size_changed", self, "_update_position")
	

func _update_position():
	var player = get_tree().get_root().get_node("Game/Player")
	var label = $Label
	var camera = get_tree().get_root().get_camera()
	
	var offset = Vector2(label.get_size().x / 2, 0)
	var node_height = Vector3(0, 2, 0)
	var pos = camera.unproject_position(player.get_translation() + node_height) - offset
	label.set_position(pos)