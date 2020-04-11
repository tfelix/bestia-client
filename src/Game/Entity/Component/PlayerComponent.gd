extends Component
class_name PlayerComponent

const CharacterLabel = preload("res://UI/CharacterLabel/CharacterLabel.tscn")

const NAME = "PlayerComponent"

export(String) var player_name = ""
export(String) var guild_name = ""
export(String) var emblem = ""
export var account_id: int = 0
export var player_bestia_id: int = 0

var _char_label = null

func _ready() -> void:
	_char_label = CharacterLabel.instance()
	_char_label.init(player_name, guild_name)
	_char_label.visible = false

func get_name() -> String:
	return NAME


func on_attach(entity) -> void:
	entity_id = entity.id
	entity.get_spatial().add_child(_char_label)


func on_remove(entity) -> void:
	if _char_label != null:
		_char_label.queue_free()
		_char_label = null


func on_mouse_entered(entity) -> void:
	_char_label.visible = true


func on_mouse_exited(entity) -> void:
	_char_label.visible = false
