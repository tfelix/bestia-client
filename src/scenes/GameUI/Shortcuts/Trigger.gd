class_name Trigger

var icon: String

func trigger_action(shortcut_action_name: String) -> void:
	pass


func to_json_dict():
	print_debug("Trigger does not overwrite to_json_dict")
	return null