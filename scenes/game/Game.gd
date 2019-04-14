extends Spatial

# I dont like it. This creation should be responsiblity of the chat node so this code is 
# not scattered around the engine.
# However we must think how this will work when there are multiple player/entities in the world
# who might need a chat hover text.
var HoverChatText = preload("res://scenes/game/chat/ChatHoverText.tscn")

func _on_GameUI_on_chat_send(text):
	var chat_text = HoverChatText.instance()
	chat_text.set_text(text)
	$Player.add_child(chat_text)
