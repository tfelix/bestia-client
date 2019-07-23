extends Node

var cursor_hand = load("res://scenes/GameUI/cursor/cursor-hand.png")
var cursor_attack = load("res://scenes/GameUI/cursor/cursor-attack.png")
var cursor_skill = load("res://scenes/GameUI/cursor/cursor-skill.png")

enum Cursor {
	NORMAL,
	SKILL,
	ATTACK,
	NONE
}

func _ready():
	Input.set_custom_mouse_cursor(cursor_attack)

func change_cursor(cursorType: int) -> void:
	Input.set_mouse_mode(0)
	match cursorType:
		Cursor.NORMAL:
			Input.set_custom_mouse_cursor(cursor_hand)
		Cursor.ATTACK:
			Input.set_custom_mouse_cursor(cursor_attack)
		Cursor.SKILL:
			Input.set_custom_mouse_cursor(cursor_skill)
		Cursor.NONE:
			Input.set_mouse_mode(1)
