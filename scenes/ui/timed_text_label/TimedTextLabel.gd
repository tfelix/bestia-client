extends RichTextLabel
class_name TimedTextLabel

export var appearing_text: String = ""
export var wait_time_ms: int = 50

signal text_appeared(appeared_text)

func _ready():
	set_text(appearing_text)
	visible_characters = 0
	$Timer.wait_time = wait_time_ms / 1000.0

func start():
	$Timer.start()

func _on_Timer_timeout():
	visible_characters += 1
	if visible_characters == appearing_text.length():
		emit_signal("text_appeared", appearing_text)
