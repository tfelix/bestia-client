extends Interaction

export(NodePath) var interaction_range_path

var interaction_range: InteractionRange

func _ready():
	assert(!interaction_range_path.is_empty())
	interaction_range = get_node(interaction_range_path)

# Triggers the interaction with a certain entity.
# It is called if the player clicks on it and it now
# must handle this interaction request.
func trigger_interaction(node: Entity):
	if interaction_range.is_player_in_range():
		print_debug("Chop the tree!")
	else:
		print_debug("Player Is Not In Range")

func insert_ui_child(node: InteractionsUi):
	var ui = load("res://scenes/Game/Interactions/ChopTree/ChopTreeUi.tscn")
	var ui_node = ui.instance()
	node.add_interaction_ui(ui_node)
