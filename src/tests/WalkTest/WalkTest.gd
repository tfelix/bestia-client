extends Spatial


"""
Perform some needed setup for single player mode.
"""
func _ready():
	GlobalData.client_account_id = 1
	
	# Test Borderless feature, make this optional via config
	#OS.set_borderless_window(true)
	#OS.set_window_size(OS.get_screen_size())
	#OS.set_window_position(Vector2(0, 0))
