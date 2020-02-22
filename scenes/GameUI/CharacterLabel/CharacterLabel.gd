extends Control

var _camera: Camera

export var character_name: String = "Player"

onready var _container = $Container
onready var _name_label = $Container/Rows/Name

func _ready():
	_camera = get_tree().get_root().get_camera()
	_name_label.text = character_name


func _process(delta):
	if _container == null:
		return
	var d_pos = Vector2(-_container.rect_size.x / 2, 20)
	var parent_pos = (get_parent() as Spatial).transform.origin
	var pos = _camera.unproject_position(parent_pos)
	self.set_position(pos + d_pos)
