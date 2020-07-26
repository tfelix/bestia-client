extends Spatial


const GameMenu = preload("res://UI/GameMenu/GameMenu.tscn")

"""
Perform some needed setup for single player mode.
"""
func _ready():
	GlobalData.client_account_id = 1
	
	# Test Borderless feature, make this optional via config
	#OS.set_borderless_window(true)
	#OS.set_window_size(OS.get_screen_size())
	#OS.set_window_position(Vector2(0, 0))


func _show_game_menu() -> void:
	var menu = GameMenu.instance()
	add_child(menu)


func _unhandled_key_input(event: InputEventKey):
	if event.is_action_pressed("ui_cancel"):
		_show_game_menu()
