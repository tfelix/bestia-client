extends Control

var _camera: Camera

onready var _name_label = $Name

func _ready():
	_camera = get_tree().get_root().get_camera()


func set_mob_name(mob_name) -> void:
	_name_label.text = mob_name


func _process(delta):
	if _name_label == null:
		return
	var d_pos = Vector2(-_name_label.rect_size.x / 2, 20)
	var parent_pos = (get_parent() as Spatial).transform.origin
	var pos = _camera.unproject_position(parent_pos)
	self.set_position(pos + d_pos)
