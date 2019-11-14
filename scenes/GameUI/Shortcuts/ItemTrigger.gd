extends Trigger
class_name ItemTrigger

var player_item_id: int

func triggerAction():
	print_debug("SC triggered pid: ", player_item_id)
	PubSub.publish(PST.SHORTCUT_ITEM_USED, player_item_id)