extends Control

signal finished()

func start():
	$TimedLabel.start()

func _on_TimedLabel_text_appeared(appeared_text):
	emit_signal("finished")
