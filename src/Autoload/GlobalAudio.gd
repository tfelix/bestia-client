extends Node

onready var _player = $BGMStreamPlayer

func _ready():
	update_volumes()

func update_volumes():
	# Update master volume
	var master_volume = float(GlobalConfig.get_value(GlobalConfig.SEC_AUDIO, GlobalConfig.PROP_AUDIO_MASTER_VOLUME, "1"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), _get_db_value(master_volume))
	
	var fx_volume = float(GlobalConfig.get_value(GlobalConfig.SEC_AUDIO, GlobalConfig.PROP_AUDIO_FX_VOLUME, "1"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Fx"), _get_db_value(fx_volume))
	
	var music_volume = float(GlobalConfig.get_value(GlobalConfig.SEC_AUDIO, GlobalConfig.PROP_AUDIO_MUSIC_VOLUME, "1"))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), _get_db_value(music_volume))


func play_bgm(stream: AudioStream):
	_player.stream = stream


"""
Transforms the 0-1 range of volume value to the range of
0- -72db the server expects.
"""
func _get_db_value(value: float) -> float:
	assert(value >= 0 && value <= 1)
	return -72 * (1 - value)
