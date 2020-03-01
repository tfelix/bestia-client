extends Trigger
class_name SkillTrigger

var player_attack_id: int

func trigger_action(shortcut_action_name: String):
	print_debug("Attack ", player_attack_id, " triggered")
	GlobalEvents.emit_signal("onCastStarted")
	# Promote as Pointer Receiver
	# This is shit we need to have a better system.
	# var click_handler = SkillCastEntityClickedHandler.new(player_attack_id)
	# Wait for receiving call


func clicked_target():
	GlobalEvents.emit_signal("onCastEnded", player_attack_id)
	print_debug("received target, can send skill use")


func to_json_dict():
	return {
		"clazz": "SkillTrigger",
		"player_attack_id": player_attack_id,
		"icon": icon
	}


func on_entity_clicked(entity: Entity) -> void:
	var msg = UseAttackMessage.new()
	msg.player_attack_id = player_attack_id
	msg.target_entity = entity.id
	GlobalEvents.emit_signal("onMessageSend", msg)
