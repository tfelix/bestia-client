extends Interaction

# Triggers the interaction with a certain entity.
# It is called if the player clicks on it and it now
# must handle this interaction request.
func trigger_interaction(node: Entity):
	print_debug("Chop the tree!")
	pass

func insert_ui_child(node: InteractionsUi):
	var ui = load("res://scenes/Game/Interactions/ChopTree/ChopTreeUi.tscn")
	var ui_node = ui.instance()
	node.add_interaction_ui(ui_node)
