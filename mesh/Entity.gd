extends Node
class_name Entity

var Actions = load("res://Actions.gd")

# Base class for all adressable entities in the bestia game.
# The entity will be managed by the network manager and filled
# with data from the server.
enum EntityKind {
	ITEM, 
	STRUCTURE, 
	NPC,
	VEGETATION
}

var id = 0
export (EntityKind) var entity_kind = EntityKind.ITEM

# The clicking should work like so:
# Select the object and see if there is a default behavior
# yes: - des the behavior need physical placement beside the object
# - yes -- Move towards object
# - no -- Execute behavior
# no: - Select the object and show all possible actions
func _on_Collidor_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		_handle_default_input()
	if event.is_action_pressed(Actions.ACTION_RIGHT_CLICK):
		_handle_secondary_input()


func _handle_default_input():
	if $Selection.is_selected:
		$Selection.unselected()
		$Interactions.abort_interaction()
	else:
		if $Interactions.has_default_interaction(self):
			$Interactions.trigger_interaction(self)
		else:
			$Interactions.show_possible_interactions()
			$Selection.selected()

func _handle_secondary_input():
	if $Selection.is_selected:
		$Selection.unselected()
		$Interactions.abort_interaction()
	else:
		$Interactions.show_possible_interactions()
		$Selection.selected()

func _on_Collidor_mouse_entered():
  print_debug("Mouse entered")
  pass # Replace with function body.


func _on_Collidor_mouse_exited():
  print_debug("Mouse exit")
  pass # Replace with function body.
