extends PanelContainer

export(String) var shortcut_action_name = "shortcut_1"

func _ready():
	var firstAction = InputMap.get_action_list(shortcut_action_name)[0]
	$ShortcutContainer/Label.text = firstAction.as_text()

func _unhandled_key_input(event):
	if event.is_action_pressed(shortcut_action_name):
		print_debug("Action pressed ", shortcut_action_name)
