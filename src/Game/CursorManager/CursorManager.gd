"""
Responsible for displaying the right cursor image when hovering over entites.
"""
extends Node
class_name CursorManager

export(Resource) var cursor_skill
export(Resource) var cursor_attack
export(Resource) var cursor_hand
export(Resource) var cursor_interact
export(Resource) var cursor_pickup

var _is_over_entity = false
var _is_over_ui = false
var _is_casting = false
var _is_constructing = false
var _is_pre_constructing = false

var _behavior_service = BehaviorService.new()
var _current_hovered_entity: Entity = null

func _ready():
	_adapt_mouse_icon(cursor_hand)
	GlobalEvents.connect("onEntityMouseEntered", self, "_entity_entered")
	GlobalEvents.connect("onEntityMouseExited", self, "_entity_exited")
	GlobalEvents.connect("onCastSelectionStarted", self, "_cast_selection_started")
	GlobalEvents.connect("onCastSelectionEnded", self, "_cast_selection_ended")
	GlobalEvents.connect("onUiEntered", self, "_ui_entered")
	GlobalEvents.connect("onUiExited", self, "_ui_exited")
	GlobalEvents.connect("onStructureConstructionStarted", self, "_started_pre_construction")
	GlobalEvents.connect("onStructureConstructionEnded", self, "_ended_pre_construction")


func _started_pre_construction(entity) -> void:
	_is_pre_constructing = true
	_check_cursor()


func _ended_pre_construction(entity) -> void:
	_is_pre_constructing = false
	_check_cursor()


func _started_construction(entity) -> void:
	_is_constructing = true
	_check_cursor()


func _ended_construction(entity) -> void:
	_is_constructing = false
	_check_cursor()


func _cast_selection_started(attack) -> void:
	_is_casting = true
	_check_cursor()


func _cast_selection_ended() -> void:
	_is_casting = false
	_check_cursor()


func _ui_entered() -> void:
	_is_over_ui = true
	_check_cursor()


func _ui_exited() -> void:
	_is_over_ui = false
	_check_cursor()


func _entity_entered(entity) -> void:
	_is_over_entity = true
	_current_hovered_entity = entity
	_check_cursor()


func _entity_exited(entity) -> void:
	_is_over_entity = false
	_current_hovered_entity = null
	_check_cursor()


func _check_cursor() -> void:
	if _is_over_ui:
		_show_default_icon()
		return
		
	if _is_pre_constructing:
		_show_default_icon()
		return

	if _is_constructing:
		_hide_mouse_icon()
		return
	
	if _is_casting:
		_adapt_mouse_icon(cursor_skill)
		return

	if _is_over_entity:
		_on_over_entity_cursor()
		return
	
	_adapt_mouse_icon(cursor_hand)

"""
Adapts the cursor to the current entity type which is under the pointer
and depending on the setup behavior it will change the cursor type.
"""
func _on_over_entity_cursor() -> void:
	var behavior = _behavior_service.get_behavior_for(_current_hovered_entity)
	print_debug("Entity Cursor behavior: ", behavior)
	match behavior:
		"attack":
			_adapt_mouse_icon(cursor_attack)
		"interact":
			_adapt_mouse_icon(cursor_interact)
		"pickup":
			_adapt_mouse_icon(cursor_pickup)
		_:
			_adapt_mouse_icon(cursor_interact)


func _reset_cursor(entity: Entity) -> void:
	if _is_constructing:
		return
	_adapt_mouse_icon(cursor_hand)


func _show_default_icon() -> void:
	Input.set_custom_mouse_cursor(null)
	Input.set_mouse_mode(0)


func _hide_mouse_icon() -> void:
	Input.set_custom_mouse_cursor(null)
	Input.set_mouse_mode(1)


func _adapt_mouse_icon(cursorType) -> void:
	Input.set_custom_mouse_cursor(cursorType)
	Input.set_mouse_mode(0)
