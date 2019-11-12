extends Node

var cursor_hand = preload("res://scenes/GameUI/cursor/cursor-hand.png")
var cursor_attack = preload("res://scenes/GameUI/cursor/cursor-attack.png")
var cursor_skill = preload("res://scenes/GameUI/cursor/cursor-skill.png")

var _cursor_stack = []

func _ready():
	_adapt_mouse_icon(Cursor.Type.NORMAL)
	PubSub.subscribe(PST.CURSOR_CHANGE, self)
	PubSub.subscribe(PST.CURSOR_RESET, self)


func free():
  PubSub.unsubscribe(self)
  .free()


func event_published(event_key, payload) -> void:
	match (event_key):
		PST.CURSOR_CHANGE:
			change_cursor(payload)
		PST.CURSOR_RESET:
			reset_cursor(payload)


func _find_cursor_by_identifier(identifier) -> int:
	var idx = 0
	for c in _cursor_stack:
		if c.identifier == identifier:
			return idx
		idx += 1
	return -1


func reset_cursor(identifier: String) -> void:
	var pos = _find_cursor_by_identifier(identifier)
	if pos != -1:
		_cursor_stack.remove(pos)
		if _cursor_stack.empty():
			_adapt_mouse_icon(Cursor.Type.NORMAL)
		else:
			var type = _cursor_stack[0].type
			_adapt_mouse_icon(type)


func change_cursor(request: CursorRequest) -> void:
	_cursor_stack.push_front(request)
	_adapt_mouse_icon(request.type)


func _adapt_mouse_icon(cursorType: int) -> void:
	Input.set_mouse_mode(0)
	match cursorType:
		Cursor.Type.NORMAL:
			Input.set_custom_mouse_cursor(cursor_hand)
		Cursor.Type.ATTACK:
			Input.set_custom_mouse_cursor(cursor_attack)
		Cursor.Type.SKILL:
			Input.set_custom_mouse_cursor(cursor_skill)
		Cursor.Type.HIDDEN:
			Input.set_mouse_mode(1)
		Cursor.Type.DEFAULT:
			Input.set_custom_mouse_cursor(null)
			Input.set_mouse_mode(0)
			
		_:
			printerr("Unknown cursortype send")