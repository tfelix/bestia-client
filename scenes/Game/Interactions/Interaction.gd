extends Node
class_name Interaction

export var interaction_node_name = ""

func save_global_default_behavior():
	assert(!interaction_node_name.empty())
	# We are a child of the InteractionsUi which will get a entity reference.
	var interactions = find_parent("Interactions")
	var interactions_ui = find_parent("InteractionsUi")
	var entity = interactions_ui.entity
	var entity_kind = entity.entity_kind
	Global.default_interactions[entity_kind] = interaction_node_name
	$AcceptClick.play()
	interactions.abort_interaction()

# Override this function so every interaction can inject its own
# UI into the UI manager.
func insert_ui_child(node: InteractionsUi):
	printerr("insert_ui_child was not overriden")
	pass

# Triggers the interaction with a certain entity.
# It is called if the player clicks on it and it now
# must handle this interaction request.
func trigger_interaction(node: Entity):
	if node.is_player_in_range():
		# Try to move to the entity location
		print_debug("player not in range")
	printerr("trigger_interaction was not overriden")

# This is strange and we need another way so we dont need to override
# the parent function.
func _on_TextureButton_pressed():
	save_global_default_behavior()
	pass # Replace with function body.
