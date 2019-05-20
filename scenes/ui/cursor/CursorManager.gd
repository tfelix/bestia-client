extends Node

var cursorHand = load("res://scenes/ui/cursor/cursor-hand.png")
var cursorAttack = load("res://scenes/ui/cursor/cursor-attack.png")

enum Cursor {
	NORMAL,
	ATTACK,
	NONE
}

# A better approach would be scan every frame with a raycast what is under
# the mouse and then ask the cursor nodes which cursor should be displayed.
# More and more cursors can be added then as sub nodes.

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
