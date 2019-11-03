extends PanelContainer

signal pressed

export(bool) var enabled = true
export(String) var shortcut_action_name = "shortcut_1"

onready var _color_player = $ColorPlayer
onready var _label = $Container/Label
onready var _icon = $Container/Icon

var _saved_trigger: Trigger

func _ready():
	var actions = InputMap.get_action_list(shortcut_action_name)
	if actions == null || actions.size() == 0:
		printerr("No action found for shortcut name: " + shortcut_action_name)
		return
	var firstAction = actions[0]
	_label.text = firstAction.as_text()

func add_trigger(trigger: Trigger):
	_icon.texture = trigger.icon
	_saved_trigger = trigger

func _unhandled_key_input(event):
	if !enabled:
		return
	if !event.is_action_pressed(shortcut_action_name):
		return
	_color_player.seek(0)
	_color_player.play("flash")
	if _saved_trigger != null:
		_saved_trigger.triggerAction()
