extends PanelContainer

var selected_style = preload("res://UI/ColorPicker/Color/ColorSelected.tres")
var normal_style = preload("res://UI/ColorPicker/Color/ColorNormal.tres")

signal selected

export var color: Color

var _selected_style_local
var _normal_style_local

func _ready():
	_selected_style_local = selected_style.duplicate()
	_normal_style_local = normal_style.duplicate()
	_selected_style_local.set_bg_color(color)
	_normal_style_local.set_bg_color(color)
	set("custom_styles/panel", _normal_style_local)


func unselect() -> void:
	set("custom_styles/panel", _normal_style_local)


func _on_Color_gui_input(event):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		set("custom_styles/panel", _selected_style_local)
		emit_signal("selected", self)
