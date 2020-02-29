extends Trigger
class_name SkillTrigger

var player_attack_id: int

func trigger_action(shortcut_action_name: String):
	print_debug("Attack ", player_attack_id, " triggered")
	# Promote as Pointer Receiver
	# This is shit we need to have a better system.
	# var click_handler = SkillCastEntityClickedHandler.new(player_attack_id)
	# Wait for receiving call


func clicked_target():
	print_debug("received target, can send skill use")


func to_json_dict():
	return {
		"clazz": "SkillTrigger",
		"player_attack_id": player_attack_id,
		"icon": icon
	}
