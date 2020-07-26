extends PanelContainer

var _is_dragging = false
var _mouse_offset: Vector2 = Vector2(0, 0)


func _ready():
	# Setup the initial position
	var win_pos = GlobalConfig.get_value(GlobalConfig.SEC_WIN_POS, GlobalConfig.PROP_WIN_EQUIP, Vector2(100, 100))
	rect_position = Vector2(win_pos)


func _on_Title_close_clicked():
	hide()


func _process(delta):
	if _is_dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		rect_position = mouse_pos - _mouse_offset


func _on_Title_drag_started(mouse_offset):
	_mouse_offset = mouse_offset
	_is_dragging = true


func _on_Title_drag_ended():
	_is_dragging = false
	GlobalConfig.set_value(GlobalConfig.SEC_WIN_POS, GlobalConfig.PROP_WIN_EQUIP, rect_position)


func _unhandled_key_input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		hide()
	if event.is_action_pressed("ui_equipment"):
		get_tree().set_input_as_handled()
		if visible:
			hide()
		else:
			show()
