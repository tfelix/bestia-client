extends Control
class_name InteractionButton

export var interaction_node_name = ""

func _save_global_default_behavior():
	assert(!interaction_node_name.empty())
	# We are a child of the InteractionsUi which will get a entity reference.
	var entity = find_parent("Interactions").entity
	var entity_kind = entity.entity_kind
	Global.default_interactions[entity_kind] = interaction_node_name

func _on_ChopTreeUi_pressed():
	_save_global_default_behavior()
	pass # Replace with function body.
