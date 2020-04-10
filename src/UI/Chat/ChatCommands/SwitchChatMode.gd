extends ChatCommand

export(NodePath) var chat_panel

onready var _chat = get_node(chat_panel)
var _matcher: RegEx

func _ready():
	_matcher = RegEx.new()
	_matcher.compile("([\/s|\/p|\/g]) (.*)")

func handle_input(text: String) -> bool:
	var result = _matcher.search(text)
	if !result:
		return false
	
	var mode = result.get_string(1)
	var chat_text = result.get_string(2)
	
	match mode:
		"s":
			_chat.set_chat_mode(ChatMessage.ChatType.PUBLIC)
		"p":
			_chat.set_chat_mode(ChatMessage.ChatType.PARTY)
		"g":
			_chat.set_chat_mode(ChatMessage.ChatType.GUILD)
	
	_chat.entered_chat(chat_text)
	
	return true 
