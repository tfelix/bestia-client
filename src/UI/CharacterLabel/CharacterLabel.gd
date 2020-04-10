extends Control
class_name CharacterLabel

var _camera: Camera

var _guild_name = "Guild"
var _player_name = "Player"
var _emblem = ""

onready var _container = $Container
onready var _name_label = $Container/Rows/Name
onready var _guild_label = $Container/Rows/Guild

func _ready():
	_camera = get_tree().get_root().get_camera()
	_name_label.text = _player_name
	if _guild_name == null:
		_guild_label.visible = false
	else:
		_guild_label.text = _guild_name


func init(player_name, guild_name):
	_player_name = player_name
	_guild_name = guild_name


func _process(delta):
	if _container == null:
		return
	var d_pos = Vector2(-_container.rect_size.x / 2, 20)
	var parent_pos = (get_parent() as Spatial).transform.origin
	var pos = _camera.unproject_position(parent_pos)
	self.set_position(pos + d_pos)
