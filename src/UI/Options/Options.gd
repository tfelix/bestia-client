extends Control

onready var _master_volume_label = $PanelContainer/MarginContainer/Rows/GridContainer/VolumeContainer/Volume
onready var _fx_volume_label = $PanelContainer/MarginContainer/Rows/GridContainer/FxVolumeContainer/Volume
onready var _music_volume_label = $PanelContainer/MarginContainer/Rows/GridContainer/MusicVolumeContainer/Volume

onready var _master_slider = $PanelContainer/MarginContainer/Rows/GridContainer/VolumeContainer/MasterVolumeSlider
onready var _fx_slider = $PanelContainer/MarginContainer/Rows/GridContainer/FxVolumeContainer/FxVolumeSlider
onready var _music_slider = $PanelContainer/MarginContainer/Rows/GridContainer/MusicVolumeContainer/MusicVolumeSlider

func _ready():
	# Setup the initial values
	_master_slider.value = float(GlobalConfig.get_value(GlobalConfig.SEC_AUDIO, GlobalConfig.PROP_AUDIO_MASTER_VOLUME, "1")) * 100
	_fx_slider.value = float(GlobalConfig.get_value(GlobalConfig.SEC_AUDIO, GlobalConfig.PROP_AUDIO_FX_VOLUME, "1")) * 100
	_music_slider.value = float(GlobalConfig.get_value(GlobalConfig.SEC_AUDIO, GlobalConfig.PROP_AUDIO_MUSIC_VOLUME, "1")) * 100

func _on_MasterVolumeSlider_value_changed(value):
	_master_volume_label.text = "%s %%" % value
	GlobalConfig.set_value(GlobalConfig.SEC_AUDIO, GlobalConfig.PROP_AUDIO_MASTER_VOLUME, value / 100.0)
	GlobalAudio.update_volumes()


func _on_FxVolumeSlider_value_changed(value):
	_fx_volume_label.text = "%s %%" % value
	GlobalConfig.set_value(GlobalConfig.SEC_AUDIO, GlobalConfig.PROP_AUDIO_FX_VOLUME, value / 100.0)
	GlobalAudio.update_volumes()


func _on_MusicVolumeSlider_value_changed(value):
	_music_volume_label.text = "%s %%" % value
	GlobalConfig.set_value(GlobalConfig.SEC_AUDIO, GlobalConfig.PROP_AUDIO_MUSIC_VOLUME, value / 100.0)
	GlobalAudio.update_volumes()


func _on_BackButton_pressed():
	get_tree().change_scene("res://UI/MainScreen/MainScreen.tscn")
