extends Node
class_name Interaction

# Override this function so every interaction can inject its own
# UI into the UI manager.
func insert_ui_child(node: InteractionsUi):
	printerr("insert_ui_child was not overriden")
	pass

# Triggers the interaction with a certain entity.
# It is called if the player clicks on it and it now
# must handle this interaction request.
func trigger_interaction(node: Entity):
	printerr("trigger_interaction was not overriden")
	pass