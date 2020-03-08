extends PanelContainer

const placeholder_img = preload("res://scenes/GameUI/Inventory/item_placeholder.png")

signal shortcut_clicked(shortcut, action_name)

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


func to_json_dict():
	if _saved_trigger == null:
		return null
	else:
		return _saved_trigger.to_json_dict()


func add_trigger(trigger: Trigger):
	_icon.texture = load(trigger.icon)
	if _icon.texture == null:
		_icon.texture = placeholder_img
	_saved_trigger = trigger


func _trigger_shortcut():
	if !enabled:
		return
	if _saved_trigger != null:
		_saved_trigger.trigger_action(shortcut_action_name)
		GlobalEvents.emit_signal("onShortcutPressed", shortcut_action_name, "attack-1")
		_color_player.seek(0)
		_color_player.play("flash")


func _unhandled_key_input(event) -> void:
	if !event.is_action_pressed(shortcut_action_name):
		return
	_trigger_shortcut()


func _on_Shortcut_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click"):
			emit_signal("shortcut_clicked", shortcut_action_name, self)
			_trigger_shortcut()
