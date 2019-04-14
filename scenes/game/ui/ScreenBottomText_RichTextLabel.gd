extends RichTextLabel

func _on_Timer_timeout():
	visible_characters += 1

func set_text(text: String):
	bbcode_text = text
	visible_characters = 0
