extends Node

const config_file = "user://game.cfg"

var _config

func _ready():
	_config = ConfigFile.new()
	var err = _config.load(config_file)
	if err != OK:
		printerr("Could not load config file: ", err)


func get_value(section: String, property: String, default_value):
	return _config.get_value(section, property, default_value)


func set_value(section: String, property: String, value):
	_config.set_value(section, property, value)
	_config.save(config_file)
