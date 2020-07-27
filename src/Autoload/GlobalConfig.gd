extends Node

const config_file = "user://game.cfg"

const SEC_AUDIO = "audio"
const SEC_WIN_POS = "win_position"
const SEC_VIDEO = "video"
const SEC_MISC = "misc"

const PROP_AUDIO_MASTER_VOLUME = "master_volume"
const PROP_AUDIO_FX_VOLUME = "fx_volume"
const PROP_AUDIO_MUSIC_VOLUME = "music_volume"

const PROP_WIN_EQUIP = "win_equipment"
const PROP_WIN_INVENTORY = "win_inventory"
const PROP_WIN_STATUS = "win_status"
const PROP_WIN_ATTACKS = "win_attacks"

const PROP_VIDEO_BORDERLESS_WIN = "borderless_win"
const PROP_VIDEO_RESOLUTION = "resolution"

const PROP_MISC_PLAYED_INTRO = "intro_played"

var _config

func _ready():
	_config = ConfigFile.new()
	var err = _config.load(config_file)
	if err != OK:
		printerr("Could not load config file: ", err)


func get_value(section: String, property: String, default_value = null):
	return _config.get_value(section, property, default_value)


func set_value(section: String, property: String, value):
	_config.set_value(section, property, value)
	_config.save(config_file)

"""
Save when the engine is exiting.
"""
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_config.save(config_file)
