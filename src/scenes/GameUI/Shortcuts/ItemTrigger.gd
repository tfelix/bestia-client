extends Trigger
class_name ItemTrigger

var player_item_id: int

func trigger_action(shortcut_action_name: String):
	print_debug("SC triggered pid: ", player_item_id)
	# Check if its not smarter to put an item into the trigger and then
	# contain the item used logic in the item itself instead of doing the trip
	GlobalEvents.emit_signal("onItemUsed", player_item_id)


func to_json_dict():
	return {
		"clazz": "ItemTrigger",
		"player_item_id": player_item_id,
		"icon": icon
	}
