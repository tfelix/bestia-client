extends Control

onready var _version_label = $Version

func _ready():
	if ProjectSettings.has_setting("application/config/version"):
		_version_label.text = "v" + ProjectSettings.get("application/config/version")
