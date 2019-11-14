extends PanelContainer

const HoverChatText = preload("res://scenes/GameUI/chat/ChatHoverText/ChatHoverText.tscn")
const ChatRow = preload("res://scenes/GameUI/Chat/ChatRow/ChatRow.tscn")

const MAX_CHAT_COUNT = 30

onready var _chat_cmds = $ChatCommands
onready var _chat_type = $MarginContainer/ChatContent/InputLine/ChatType
onready var _chat_line_container = $MarginContainer/ChatContent/ScrollContainer/Lines
onready var _text_input = $MarginContainer/ChatContent/InputLine/Text
onready var _animation = $AnimationPlayer as AnimationPlayer

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


func entered_chat(text: String) -> void:
	_clear_text()
	if text.length() == 0:
		return
	
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


func _display_hover_chat(msg: ChatMessage) -> void:
	var entity = Global.entities.get_entity(msg.entity_id)
	# Maybe do this via a local component?
	if entity != null:
		var chat_text = HoverChatText.instance()
		entity.add_child(chat_text)
		chat_text.set_text(msg.text)
	else:
		print_debug("_display_hover_chat: Entity with id ", msg.entity_id, " not found")


func _on_Text_text_entered(new_text):
	entered_chat(new_text)
	# Small trick to remove the focus from the control so the game can 
	# react on control inputs again
	_text_input.focus_mode = FOCUS_NONE
	_text_input.focus_mode = FOCUS_CLICK


func _on_ChatPanel_mouse_entered():
	var request = CursorRequest.new()
	request.identifier = "chat"
	request.type = Cursor.Type.DEFAULT
	PubSub.publish(PST.CURSOR_CHANGE, request)
	_animation.play("show")


func _on_ChatPanel_mouse_exited():
	PubSub.publish(PST.CURSOR_RESET, "chat")
	_animation.play("hide")


# Strange it seems this is only triggered if we are in "focus" of some control element.
# we might need to capture globally events here to get it.
func _on_ChatPanel_gui_input(event):
	if event is InputEventKey:
		if event.pressed && event.scancode == KEY_ENTER:
			_text_input.grab_focus()
