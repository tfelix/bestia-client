extends Control
class_name CharacterLabel

onready var _name_label = $Rows/Name
onready var _guild_label = $Rows/Guild


func set_data(component: PlayerComponent):
	_name_label.text = component.player_name
	_guild_label.text = component.guild_name
