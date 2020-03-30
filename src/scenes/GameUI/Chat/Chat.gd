extends VBoxContainer

const HoverChatText = preload("res://scenes/GameUI/chat/ChatHoverText/ChatHoverText.tscn")
const ChatRow = preload("res://scenes/GameUI/Chat/ChatRow/ChatRow.tscn")

const MAX_CHAT_COUNT = 50

onready var _chat_cmds = $ChatCommands
onready var _chat_type = $InputMargin/InputPanel/InputLine/ChatType
onready var _chat_line_container = $ChatPanel/MarginContainer/ChatContent/ScrollContainer/Lines
onready var _text_input = $InputMargin/InputPanel/InputLine/Text
onready var _animation = $AnimationPlayer as AnimationPlayer

var _has_mouse_over = false

func _ready():
	_chat_type.add_item("Public")
	_chat_type.add_item("Party")
	_chat_type.add_item("Guild")
	GlobalEvents.connect("onChatReceived", self, "_insert_chat_text")


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
	GlobalEvents.emit_signal("onMessageSend", chat_send)
	call_deferred("_release_focus")

"""
Must be called deffered in order to avoid that the enter event
does grab focus again right away.
"""
func _release_focus():
	_text_input.release_focus()


func print_text(text) -> void:
	var msg = ChatMessage.new()
	msg.entity_id = 0
	msg.text = text
	msg.type = ChatMessage.ChatType.SYSTEM
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


func _on_Text_text_entered(new_text):
	entered_chat(new_text)
	_try_play_hide()


func _unhandled_key_input(event):
	if Input.is_key_pressed(KEY_ENTER) && !_text_input.has_focus():
		_text_input.grab_focus()


func _show() -> void:
	if _animation.current_animation == "hide":
		_animation.stop()
	self_modulate = Color(1.0, 1.0, 1.0, 1.0)


func _try_play_hide() -> void:
	if not _text_input.has_focus() && not _has_mouse_over:
		_animation.play("hide")


func _on_Chat_mouse_entered():
	GlobalEvents.emit_signal("onUiEntered")
	_has_mouse_over = true
	_show()


func _on_Chat_mouse_exited():
	_has_mouse_over = false
	GlobalEvents.emit_signal("onUiExited")
	_try_play_hide()
