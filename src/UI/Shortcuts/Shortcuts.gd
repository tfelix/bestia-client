extends VBoxContainer

onready var _row_1 = $Row1
onready var _row_2 = $Row2

export var shortcuts_enabled = false setget shortcuts_enabled_set

var _shortcuts

func _ready():
	_shortcuts = _row_1.get_children() + _row_2.get_children()
	_connect_shortcut_singals()


func shortcuts_enabled_set(new_value):
	shortcuts_enabled = new_value
	for sc in _shortcuts:
		sc.enabled = shortcuts_enabled


func _connect_shortcut_singals() -> void:
	for sc in _shortcuts:
		sc.connect("shortcut_clicked", self, "_on_shortcut_clicked")


func _on_shortcut_clicked(action_name, shortcut) -> void:
	# Safety check to make sure we really have shortcut data available
	if not shortcut.shortcut_data:
		print_debug("No shortcut_data available")
		return
	GlobalEvents.emit_signal("onShortcutPressed", action_name, shortcut.shortcut_data)
