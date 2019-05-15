extends Node

var cursorHand = load("res://scenes/ui/cursor/cursor-hand.png")
var cursorAttack = load("res://scenes/ui/cursor/cursor-attack.png")

enum Cursor {
	NORMAL,
	ATTACK,
	NONE
}

func _ready():
	Input.set_custom_mouse_cursor(cursorHand)

func change_cursor(cursorType: int) -> void:
	Input.set_mouse_mode(0)
	match cursorType:
		Cursor.NORMAL:
			Input.set_custom_mouse_cursor(cursorHand)
		Cursor.ATTACK:
			Input.set_custom_mouse_cursor(cursorAttack)
		Cursor.NONE:
			Input.set_mouse_mode(1)
