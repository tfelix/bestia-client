extends PanelContainer

const placeholder_img = preload("res://scenes/GameUI/Inventory/item_placeholder.png")

signal shortcut_clicked(shortcut, action_name)

export(bool) var enabled = true
export(String) var shortcut_action_name = "shortcut_1"

onready var _color_player = $ColorPlayer
onready var _label = $Container/Label
onready var _icon = $Container/Icon

var shortcut_data: ShortcutData

func _ready():
	var actions = InputMap.get_action_list(shortcut_action_name)
	if actions == null || actions.size() == 0:
		printerr("No action found for shortcut name: " + shortcut_action_name)
		return
	var firstAction = actions[0]
	_label.text = firstAction.as_text()
	GlobalData.shortcut_service.connect("shortcuts_changed", self, "_load_shortcut_data")
	_load_shortcut_data()


func _load_shortcut_data() -> void:
	shortcut_data = GlobalData.shortcut_service.get_shortcut(shortcut_action_name)
	if shortcut_data:
		_icon.texture = load(shortcut_data.icon)
	else:
		_icon.texture = null


func _trigger_shortcut_flashing() -> void:
	if not enabled:
		return
	if shortcut_data != null:
		_color_player.stop(true)
		_color_player.play("flash")


func _unhandled_key_input(event) -> void:
	if event.is_action_pressed(shortcut_action_name):
		emit_signal("shortcut_clicked", shortcut_action_name, self)
		_trigger_shortcut_flashing()


func _on_Shortcut_gui_input(event) -> void:
	if not event is InputEventMouseButton:
		return
	if event.is_action_pressed("left_click"):
		emit_signal("shortcut_clicked", shortcut_action_name, self)
		_trigger_shortcut_flashing()
	if event.is_action_pressed("right_click"):
		GlobalData.shortcut_service.delete_shortcut(shortcut_action_name)
