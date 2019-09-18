extends PanelContainer

var PST = load("res://PubSubTopics.gd")
var HoverChatText = preload("res://scenes/GameUI/chat/ChatHoverText.tscn")
const MAX_CHAT_COUNT = 30

signal on_chat_send

onready var chat_line_container = $MarginContainer/VBoxContainer/ScrollContainer/VBoxTextRow

var _chat_commands = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var textNode = $MarginContainer/VBoxContainer/HBoxContainer/Text
	textNode.connect("text_entered", self, "_on_Enter_pressed")
	PubSub.subscribe(PST.CHAT_REGISTER_CMD, self)

func free():
  PubSub.unsubscribe(self)
  .free()


func event_published(event_key, payload) -> void:
  match (event_key):
    PST.CHAT_REGISTER_CMD:
      _chat_commands.append(payload)

func _clear_text():
	$MarginContainer/VBoxContainer/HBoxContainer/Text.clear()

# TODO Better handle the support of nicknames when there is some chatting
func _insert_chat_text(text):
	var new_chat_label = Label.new()
	new_chat_label.text = text
	chat_line_container.add_child(new_chat_label)
	while chat_line_container.get_child_count() > MAX_CHAT_COUNT:
		# We need free to immediatly remove child or we have an infinite loop
		# here.
		chat_line_container.get_child(0).free()

# Send chat text to signal.
func _on_Send_pressed():
	var text = $MarginContainer/VBoxContainer/HBoxContainer/Text.text
	_entered_chat(text)

# Send chat text to signal.
func _on_Enter_pressed(text):
	_entered_chat(text)

func _entered_chat(text):
	_clear_text()
	
	# Check if a chat command handler will handle the command
	# locally
	for cmd in _chat_commands:
		if(cmd.on_chat_send(text)):
			return

	emit_signal("on_chat_send", text)
	_insert_chat_text(text)
	_display_hover_chat(text)

func _display_hover_chat(text):
	var chat_text = HoverChatText.instance()
	chat_text.set_text(text)
	Global.player.add_child(chat_text)