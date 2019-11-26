extends Trigger
class_name SkillTrigger

var skill_db_name: String
var skill_level: int

func trigger_action():
	# Change Pointer Mode
	# Promote as Pointer Receiver
	# Wait for receiving call
	print_debug("Skill ", skill_db_name, " triggered")
	pass


func clicked_target():
	print_debug("received target, can send skill use")


func to_json_dict():
	return {
		"clazz": "SkillTrigger",
		"skill_db_name": skill_db_name,
		"skill_level": skill_level,
		"icon": icon
	}