extends MarginContainer

signal close_clicked
signal drag_started
signal drag_ended

export(String) var title_text
export(Texture) var icon

onready var _title = $TitleBackground/MarginContainer/TitleRow/Title
onready var _icon = $TitleBackground/MarginContainer/TitleRow/IconMargin/Icon


func _ready() -> void:
	_title.text = title_text
	_icon.texture = icon


func _on_Close_pressed():
	emit_signal("close_clicked")


func _on_TitleBackground_gui_input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		emit_signal("drag_started", get_local_mouse_position())
	if event.is_action_released("left_click"):
		emit_signal("drag_ended")
