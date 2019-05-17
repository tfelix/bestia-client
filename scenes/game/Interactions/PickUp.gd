extends Node

func trigger_interaction(node: Spatial) -> void:
	# Is player in range for pickup?
	
	# Yes: Pickup item
	
	# No: Move player to item, as soon as he is in range, pick up
	# Send callback end of movement to player?
	# Wire to Player signal? End of movement? <-- Better
	print_debug("Move Player to item and pick up")
