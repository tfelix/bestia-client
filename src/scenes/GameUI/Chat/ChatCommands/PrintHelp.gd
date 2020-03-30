extends ChatCommand

export(NodePath) var chat

onready var _chat = get_node(chat)
var _matcher: RegEx

func _ready():
	_matcher = RegEx.new()
	_matcher.compile("\/help")

func handle_input(text: String) -> bool:
	var result = _matcher.search(text)
	if !result:
		return false
	
	var commands = get_parent()
	for c in commands.get_children():
		# Skip self
		if c == self:
			continue
		
		var usage = c.cmd_usage
		var desc = c.help_text
		_chat.print_text(usage)
		_chat.print_text(desc)
	
	return true 
