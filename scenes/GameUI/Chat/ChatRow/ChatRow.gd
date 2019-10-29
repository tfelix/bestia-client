extends HBoxContainer

onready var _username = $Username
onready var _text = $ChatText

func set_message(message: ChatMessage) -> void:
	# TODO Adapt the different colors for now there is only public chat.
	if message.username == null:
		_username.visible = false
	else:
		_username.text = message.username + ":"
	_text.text = message.text