extends VBoxContainer

var _camera: Camera

func _ready():
	# TODO Update with player bestia status values
	_camera = get_tree().get_root().get_camera()


func _process(delta):
	var d_pos = Vector2(-self.rect_size.x / 2, 0)
	var parent_pos = (get_parent() as Spatial).transform.origin
	# Correct the y offset
	parent_pos.y -= 0.7
	var pos = _camera.unproject_position(parent_pos)
	self.set_position(pos + d_pos)
