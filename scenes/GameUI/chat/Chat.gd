extends PanelContainer

var PST = load("res://PubSubTopics.gd")
var HoverChatText = preload("res://scenes/GameUI/chat/ChatHoverText/ChatHoverText.tscn")
var ChatRow = preload("res://scenes/GameUI/Chat/ChatRow/ChatRow.tscn")

const MAX_CHAT_COUNT = 30

onready var _chat_cmds = $ChatCommands
onready var _chat_type = $MarginContainer/ChatContent/InputLine/ChatType
onready var _chat_line_container = $MarginContainer/ChatContent/ScrollContainer/Lines
onready var _text_input = $MarginContainer/ChatContent/InputLine/Text

func _ready():
	_chat_type.add_item("Public")
	_chat_type.add_item("Party")
	_chat_type.add_item("Guild")

	PubSub.subscribe(PST.CHAT_RECEIVED, self)

func free():
  PubSub.unsubscribe(self)
  .free()


func event_published(event_key, payload) -> void:
	match event_key:
		PST.CHAT_RECEIVED:
			_insert_chat_text(payload)


func set_chat_mode(mode: int) -> void:
	match mode:
		ChatMessage.ChatType.PUBLIC:
			_chat_type.select(0)
			pass
		ChatMessage.ChatType.PARTY:
			_chat_type.select(1)
			pass
		ChatMessage.ChatType.GUILD:
			_chat_type.select(2)
			pass
		_:
			print_debug("Unknown chat mode: ", mode)


func entered_chat(text) -> void:
	_clear_text()
	
	# Check if a chat command handler will handle the command locally
	for cmd in _chat_cmds.get_children():
		if(cmd.handle_input(text)):
			return

	var chat_send = ChatSend.new()
	chat_send.text = text
	chat_send.type = _chat_type.selected
	PubSub.publish(PST.SERVER_SEND, chat_send)


func print_text(text) -> void:
	var msg = ChatMessage.new()
	msg.entity_id = 0
	msg.text = text
	msg.type = ChatMessage.ChatType.PUBLIC
	_insert_chat_text(msg)


func _truncate_chat_lines() -> void:
	var lines_to_delete = _chat_line_container.get_child_count() - MAX_CHAT_COUNT
	for i in range(lines_to_delete):
		_chat_line_container.get_child(i).queue_free()


func _clear_text():
	_text_input.clear()


func _insert_chat_text(msg: ChatMessage) -> void:
	var new_row = ChatRow.instance()
	_chat_line_container.add_child(new_row)
	new_row.set_message(msg)
	_truncate_chat_lines()
	_display_hover_chat(msg)


# Send chat text to signal.
func _on_Send_pressed():
	var text = $MarginContainer/VBoxContainer/HBoxContainer/Text.text
	entered_chat(text)

# Send chat text to signal.
func _on_Enter_pressed(text):
	entered_chat(text)


func _display_hover_chat(msg: ChatMessage) -> void:
	var chat_text = HoverChatText.instance()
	# TODO Find and Attach it to the entity who says it
	Global.player.add_child(chat_text)
	chat_text.set_text(msg.text)


func _on_Text_text_entered(new_text):
	entered_chat(new_text)
