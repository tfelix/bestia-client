extends Node
class_name CursorManager

export(Resource) var cursor_skill
export(Resource) var cursor_attack
export(Resource) var cursor_hand

var _is_over_ui = false
var _is_contructing = false

func _ready():
	_adapt_mouse_icon(cursor_hand)
	GlobalEvents.connect("onEntityMouseEntered", self, "_ui_entered")
	GlobalEvents.connect("onEntityMouseExited", self, "_ui_exited")
	GlobalEvents.connect("onUiEntered", self, "_check_cursor")
	GlobalEvents.connect("onEntityMouseExited", self, "_reset_cursor")
	GlobalEvents.connect("onStructureConstructionStarted", self, "_started_construction")
	GlobalEvents.connect("onStructureConstructionEnded", self, "_ended_construction")


func _started_construction(entity) -> void:
	_is_contructing = true
	_check_cursor(null)


func _ended_construction(entity) -> void:
	_is_contructing = false
	_check_cursor(null)


func _ui_entered() -> void:
	_is_over_ui = true
	_check_cursor(null)
	

func _ui_exited() -> void:
	_is_over_ui = false
	_check_cursor(null)


func _check_cursor(entity: Entity) -> void:
	if _is_over_ui:
		_show_default_icon()

	if _is_contructing:
		_hide_mouse_icon()
		return

	if entity != null:
		# Ask the default behavior for this kind of entity.
		if entity.entity_kind == Entity.EntityKind.MOB:
			_adapt_mouse_icon(cursor_attack)
		return
	
	_adapt_mouse_icon(cursor_hand)


func _reset_cursor(entity: Entity) -> void:
	if _is_contructing:
		return
	_adapt_mouse_icon(cursor_hand)


func _show_default_icon() -> void:
	Input.set_custom_mouse_cursor(null)
	Input.set_mouse_mode(1)


func _hide_mouse_icon() -> void:
	Input.set_custom_mouse_cursor(null)
	Input.set_mouse_mode(0)


func _adapt_mouse_icon(cursorType) -> void:
	Input.set_mouse_mode(0)
	Input.set_custom_mouse_cursor(cursorType)
