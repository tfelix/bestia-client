extends ChatCommand

var _matcher: RegEx

func _ready():
	_matcher = RegEx.new()
	_matcher.compile("\/debug ([true|false|0|1])")

func handle_input(text: String) -> bool:
	var result = _matcher.search(text)
	if !result:
		return false
	var mode = result.get_string(1)
	
	var mode_flag = false
	if mode == "0" || mode == "false":
		mode_flag = false
	else:
		mode_flag = true
	GlobalEvents.emit_signal("onDebugMode", mode_flag)
	
	return true 
