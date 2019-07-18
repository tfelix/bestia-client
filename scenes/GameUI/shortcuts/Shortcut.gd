extends PanelContainer

export(String) var shortcut_action_name = "shortcut_1"

onready var _color_player = $ColorPlayer
onready var _label = $Container/Label

func _ready():
	var actions = InputMap.get_action_list(shortcut_action_name)
	if actions == null || actions.size() == 0:
		printerr("No action found for shortcut name: " + shortcut_action_name)
		return
	var firstAction = actions[0]
	_label.text = firstAction.as_text()

func _unhandled_key_input(event):
	if !event.is_action_pressed(shortcut_action_name):
		return
	_color_player.seek(0)
	_color_player.play("flash")
	print_debug("Action pressed ", shortcut_action_name)
