extends Trigger
class_name ItemTrigger

var player_item_id: int

func trigger_action():
	print_debug("SC triggered pid: ", player_item_id)
	PubSub.publish(PST.SHORTCUT_ITEM_USED, player_item_id)
	

func to_json_dict():
	return {
		"clazz": "ItemTrigger",
		"player_item_id": player_item_id,
		"icon": icon
	}