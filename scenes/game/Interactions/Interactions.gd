extends Node

enum InteractionAsset {ITEM, STRUCTURE, NPC}

export (InteractionAsset) var interaction_asset

func trigger_interaction(node: Spatial) -> void:
	if !Global.default_interactions.has(interaction_asset):
		_show_possible_interaction()
	else:
		var default_interaction = Global.default_interactions[interaction_asset]
		var interaction_node = get_node(default_interaction)
		if interaction_node != null:
			interaction_node.trigger_interaction(node)
		
func _show_possible_interaction():
	print_debug("show ui possible interaction")
	pass
