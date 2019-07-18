extends Node
class_name Entity

var Actions = load("res://Actions.gd")

signal component_changed(component)
signal component_removed(component)

# Base class for all adressable entities in the bestia game.
# The entity will be managed by the network manager and filled
# with data from the server.
enum EntityKind {
	ITEM, 
	STRUCTURE, 
	NPC,
	MOB,
	VEGETATION
}

var id = 0
onready var _components = $Components

export (EntityKind) var entity_kind = EntityKind.ITEM

"""
Returns the bounding box of the mesh of this entity. Then a unit sized
cube is returned.
"""
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3.ONE)


func get_component(component_name: String) -> Component:
	return _components.find_node(component_name, false, false)
	

func update_component(component: Component):
	var old_comp = null
	for c in _components.get_children():
		if typeof(c) == typeof(component):
			old_comp = c
			break
	if !old_comp == null:
		_components.remove_child(old_comp)
	_components.add_child(component)
	emit_signal("component_changed", component)

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

