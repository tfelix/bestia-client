extends Interaction

func insert_ui_child(node: InteractionsUi):
	var ui = load("res://scenes/Game/Interactions/ChopTree/ChopTreeUi.tscn")
	var ui_node = ui.instance()
	node.add_interaction_ui(ui_node)
