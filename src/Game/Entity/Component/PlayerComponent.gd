extends Component
class_name PlayerComponent

const NAME = "PlayerComponent"

export(String) var player_name = ""
export(String) var guild_name = ""
export(String) var emblem = ""
export var account_id: int = 0
export var player_bestia_id: int = 0


func get_name() -> String:
	return NAME


func on_attach(entity) -> void:
	entity_id = entity.id
