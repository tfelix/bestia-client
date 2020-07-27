extends Node

func update_video() -> void:
	var has_borderless_win = GlobalConfig.get_value(GlobalConfig.SEC_VIDEO, GlobalConfig.PROP_VIDEO_BORDERLESS_WIN, false)
	_set_borderless_win(has_borderless_win)


func _set_borderless_win(enabled: bool) -> void:
	if enabled:
		GlobalConfig.set_value(GlobalConfig.SEC_VIDEO, GlobalConfig.PROP_VIDEO_RESOLUTION, OS.window_size)
		OS.set_borderless_window(true)
		OS.set_window_size(OS.get_screen_size())
		OS.set_window_position(Vector2(0, 0))
	else:
		OS.set_borderless_window(false)
		var old_screen_size = GlobalConfig.get_value(GlobalConfig.SEC_VIDEO, GlobalConfig.PROP_VIDEO_RESOLUTION, Vector2(800, 600))
		OS.set_window_size(old_screen_size)
