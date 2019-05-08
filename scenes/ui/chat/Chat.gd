extends PanelContainer

var HoverChatText = preload("res://scenes/ui/chat/ChatHoverText.tscn")
const MAX_CHAT_COUNT = 30

signal on_chat_send

onready var chat_line_container = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
onready var player = get_tree().get_root().get_node("Game/Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	var textNode = $MarginContainer/VBoxContainer/HBoxContainer/Text
	textNode.connect("text_entered", self, "_on_Enter_pressed")

func _clear_text():
	$MarginContainer/VBoxContainer/HBoxContainer/Text.clear()
	
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
	emit_signal("on_chat_send", text)
	_clear_text()
	_insert_chat_text(text)
	_display_hover_chat(text)

func _display_hover_chat(text):
	var chat_text = HoverChatText.instance()
	chat_text.set_text(text)
	player.add_child(chat_text)