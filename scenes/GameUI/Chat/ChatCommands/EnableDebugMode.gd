extends ChatCommand

export(NodePath) var chat_panel

onready var _chat = get_node(chat_panel)
var _matcher: RegEx

func _ready():
	_matcher = RegEx.new()
	_matcher.compile("\/debug ([true|false])")

func handle_input(text: String) -> bool:
	var result = _matcher.search(text)
	if !result:
		return false
	
	var mode = bool(result.get_string(1))
	
	# TODO Publish via pubsub
	
	return true 