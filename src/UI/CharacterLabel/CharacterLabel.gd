extends Control
class_name CharacterLabel

var _guild_name = "Guild"
var _player_name = "Player"
var _emblem = ""

onready var _name_label = $Rows/Name
onready var _guild_label = $Rows/Guild
# onready var _follower = $SpatialFollower

# We might need an extra offset if condition component is there
# and we need to display the health bars.
const extra_y_offset_condition = 50


func _ready():
	_name_label.text = _player_name
	if _guild_name == null:
		_guild_label.visible = false
	else:
		_guild_label.text = _guild_name
	# yield(owner, "ready")
	#_follower.follow_node = get_parent().get_path()
	#_follower.offset = Vector2(-rect_size.x / 2, 30)



func init(player_name, guild_name):
	_player_name = player_name
	_guild_name = guild_name
