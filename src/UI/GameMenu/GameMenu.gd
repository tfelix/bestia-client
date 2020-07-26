extends Control


func _on_ExitButton_pressed():
	get_tree().quit()


func _unhandled_key_input(event: InputEventKey):
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		queue_free()
