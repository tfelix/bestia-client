extends VBoxContainer

onready var _row_1 = $Row1
onready var _row_2 = $Row2

export var shortcuts_enabled = false setget shortcuts_enabled_set

var _shortcuts
var _prepare_shortcut_data

func _ready():
	_shortcuts = _row_1.get_children() + _row_2.get_children()
	GlobalEvents.connect("onPrepareSetShortcut", self, "_prepare_set_shortcut")
	_connect_shortcut_singals()


func _prepare_set_shortcut(shortcut_data) -> void:
	if shortcut_data:
		print_debug("_prepare_set_shortcut - type: ", shortcut_data.type , ", payload: ", to_json(shortcut_data.payload))
	else:
		print_debug("_prepare_set_shortcut - Unset shortcut preparation")
	_prepare_shortcut_data = shortcut_data


func shortcuts_enabled_set(new_value):
	shortcuts_enabled = new_value
	for sc in _shortcuts:
		sc.enabled = shortcuts_enabled


func _connect_shortcut_singals() -> void:
	for sc in _shortcuts:
		sc.connect("shortcut_clicked", self, "_on_shortcut_clicked")


func _on_shortcut_clicked(action_name, shortcut) -> void:
	if _prepare_shortcut_data:
		# setup the new shortcut instead of triggering something
		GlobalData.shortcut_service.save_shortcut(action_name, _prepare_shortcut_data)
	else:
		# Safety check to make sure we really have shortcut data available
		if not shortcut.shortcut_data:
			print_debug("No shortcut_data available")
			return
		GlobalEvents.emit_signal("onShortcutPressed", action_name, shortcut.shortcut_data)
