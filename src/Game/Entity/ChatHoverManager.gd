extends Node


const ChatHoverText = preload("res://UI/Chat/ChatHoverText/ChatHoverText.tscn")

export(NodePath) var _entites_path
var _entities


func _ready():
	_entities = get_node(_entites_path)
	GlobalEvents.connect("onMessageReceived", self, "_server_received")


func _server_received(msg) -> void:
	if not msg is ChatMessage:
		return
	_display_hover_chat(msg)


func _display_hover_chat(msg: ChatMessage) -> void:
	var entity = _entites_path.get_entity(msg.entity_id)
	if entity == null:
		print_debug("_display_hover_chat: Entity with id ", msg.entity_id, " not found")
		return
	var chat_text = ChatHoverText.instance()
	entity.add_child(chat_text)
	chat_text.set_text("%s: %s" % [msg.username, msg.text])
