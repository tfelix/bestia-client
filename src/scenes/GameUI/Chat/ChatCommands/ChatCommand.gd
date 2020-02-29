extends Node
class_name ChatCommand

export(String) var cmd_usage
export(String) var help_text

func get_help() -> String:
	return help_text


func handle_input(text: String) -> bool:
	return false
