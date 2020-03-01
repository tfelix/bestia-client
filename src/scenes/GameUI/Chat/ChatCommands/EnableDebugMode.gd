extends ChatCommand

var _matcher: RegEx

func _ready():
	_matcher = RegEx.new()
	_matcher.compile("\/debug ([true|false])")

func handle_input(text: String) -> bool:
	var result = _matcher.search(text)
	if !result:
		return false
	var mode = bool(result.get_string(1))
	print_debug("Chat CMD: debug ", mode)
	
	# TODO Publish via pubsub
	
	return true 
