extends Spatial
class_name Entity

# Base class for all adressable entities in the bestia game.
# The entity will be managed by the network manager and filled
# with data from the server.
enum EntityKind {
	ITEM, 
	STRUCTURE, 
	NPC,
	MOB,
	VEGETATION,
	PLAYER
}

const UNIT_AABB = AABB(Vector3.ZERO, Vector3.ONE)

signal component_updated(component)

export (EntityKind) var entity_kind = EntityKind.ITEM
"""
You can set a path to a VisualInstance (e.g. a MeshInstance) which then will
get used to determine the AABB.
"""
export (NodePath) var aabb_visual_instance_path
export var id = 0

onready var _interactions = $Interactions
onready var _components = $Components

var _aabb
var _is_selected = false


func _ready():
	if aabb_visual_instance_path:
		var visual_inst = get_node(aabb_visual_instance_path) as VisualInstance
		_aabb = visual_inst.get_aabb()
	else:
		_aabb = UNIT_AABB
	# As we might be already attached under the Entities node it might not
	# be subscribed to the entity signal. To give it a chance to subscribe
	# we need to call announce entity deferred.
	call_deferred("_announce_entity")


func free():
	GlobalEvents.emit_signal("onEntityRemoved", self)
	.free()


func _announce_entity():
	GlobalEvents.emit_signal("onEntityAdded", self)


"""
Returns the spatial node which resembles this entity.
"""
func get_spatial():
	return get_parent()


"""
Returns the bounding box of the mesh of this entity. Then a unit sized
cube is returned.
"""
func get_aabb() -> AABB:
	return _aabb


func handle_message(msg):
	if msg is Component:
		_components.update_component(msg)
	if msg is ComponentRemoveMessage:
		_components.remove_component(msg.component_name)


func get_component(component_name: String) -> Component:
	return _components.get_component(component_name)


func update_component(component: Component):
	_components.update_component(component)
	emit_signal("component_updated", component)


func remove_component(component_name: String):
	_components.remove_component(component_name)


func _handle_default_input() -> void:
	if _is_selected:
		_interactions.abort_interaction()
	else:
		if _interactions.has_default_interaction(self):
			_interactions.trigger_interaction(self)
		else:
			_interactions.show_possible_interactions()
	

# The clicking should work like so:
# Select the object and see if there is a default behavior
# yes: - des the behavior need physical placement beside the object
# - yes -- Move towards object
# - no -- Execute behavior
# no: - Select the object and show all possible actions
func _on_ClickBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		_handle_default_input()
		GlobalEvents.emit_signal("onEntityClicked", self, event)


func _on_ClickBody_mouse_entered():
	_components.on_mouse_entered(self)
	GlobalEvents.emit_signal("onEntityMouseEntered", self)


func _on_ClickBody_mouse_exited():
	_components.on_mouse_exited(self)
	GlobalEvents.emit_signal("onEntityMouseExited", self)
