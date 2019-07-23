extends Trigger
class_name SkillTrigger

var skill_db_name: String
var skill_level: int

func triggerAction():
	# Change Pointer Mode
	# Promote as Pointer Receiver
	# Wait for receiving call
	print_debug("Skill was triggered")
	pass
	
func clicked_target():
	print_debug("received target, can send skill use")

