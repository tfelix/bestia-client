extends Node
class_name Interactions

# Interactions have two puposes. On the one hand they should show up
# as an icon when being selected and upon click they should register
# themselve as default interaction for this kind of entity.
enum InteractionAsset {ITEM, STRUCTURE, NPC}

var InteractionUi = load("res://scenes/game/Interactions/InteractionsUi/InteractionsUi.tscn")

onready var parent = get_parent()
var ui = null

export (InteractionAsset) var interaction_asset

func _process(delta):
	if ui != null:
		var global_pos = parent.to_global(Vector3.ZERO)
		var screen_pos = Global.player_camera.unproject_position(global_pos)
		ui.margin_left = screen_pos.x
		ui.margin_top = screen_pos.y

func trigger_interaction(node: Spatial) -> void:
  if !Global.default_interactions.has(interaction_asset):
    _show_possible_interaction()
  else:
    var default_interaction = Global.default_interactions[interaction_asset]
    var interaction_node = get_node(default_interaction)
    if interaction_node != null:
      interaction_node.trigger_interaction(node)

func abort_interaction() -> void:
	if ui != null:
		ui.queue_free()
		ui = null

func _show_possible_interaction():
	if ui == null:
		ui = InteractionUi.instance()
		add_child(ui)
