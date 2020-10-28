extends Control

onready var _version_label = $Version

func _ready():
	if ProjectSettings.has_setting("application/config/version"):
		_version_label.text = "Bestia Behemoth Client v" + ProjectSettings.get("application/config/version")


func _on_TwitterLogo_gui_input(event):
	if event.is_action(Actions.ACTION_LEFT_CLICK):
		OS.shell_open("https://twitter.com/bestiagame")


func _on_DiscordLogo_gui_input(event):
	if event.is_action(Actions.ACTION_LEFT_CLICK):
		OS.shell_open("https://discord.gg/zZW8M2S")
