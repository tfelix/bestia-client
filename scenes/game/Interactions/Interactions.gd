extends Node
class_name Interactions

# Interactions have two puposes. On the one hand they should show up
# as an icon when being selected and upon click they should register
# themselve as default interaction for this kind of entity.

var InteractionUi = load("res://scenes/Game/Interactions/InteractionsUi/InteractionsUi.tscn")

onready var parent_entity = get_parent()
var ui = null

func _process(delta):
	if ui != null:
		var global_pos = parent_entity.to_global(Vector3.ZERO)
		var screen_pos = Global.player_camera.unproject_position(global_pos)
		ui.margin_left = screen_pos.x
		ui.margin_top = screen_pos.y

func trigger_interaction(node: Entity) -> void:
	if node == null:
		printerr("No interaction node given")
		return
	
	var kind = node.entity_kind
	if !Global.default_interactions.has(kind):
		_show_possible_interaction()
	else:
		var default_interaction = Global.default_interactions[kind]
		var interaction_node = get_node(default_interaction)
		if interaction_node == null:
			print("No interaction of type '", default_interaction, "' found")
			return
		interaction_node.trigger_interaction(node)

func abort_interaction() -> void:
	if ui != null:
		ui.queue_free()
		ui = null

func _show_possible_interaction():
	if ui == null:
		ui = InteractionUi.instance()
		ui.entity = parent_entity
		for n in get_children():
			n.insert_ui_child(ui)
		add_child(ui)
