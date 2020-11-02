extends Spatial
"""
Base class for all adressable entities in the bestia game.
The entity will be managed by the network manager and filled
with data from the server.
"""
class_name Entity

signal vfx_played(vfx_name)
signal component_updated(component)
signal component_removed(component_name)
signal mouse_entered()
signal mouse_exited()

"""
Server has signaled that this entity is removed.
Listenting to this signal you can play a little disappear animation.
The parent using this entity is responsible for deleting the node.
"""
signal removed()
signal used(player_entity)

enum BehaviorGroup {
	PICKUP,
	ATTACK,
	TALK,
	READ,
	USE,
	TRADE,
	CONSTRUCT,
	GATHER_RESOURCES,
	INTERACT,
	NOTHING
}

const UNIT_AABB = AABB(Vector3.ZERO, Vector3.ONE)

export (BehaviorGroup) var behavior_group = BehaviorGroup.NOTHING

"""
You can set a path to a VisualInstance (e.g. a MeshInstance) which then will
get used to determine the AABB.
"""
export (NodePath) var aabb_visual_instance_path
export var id = 0

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


func _announce_entity():
	GlobalEvents.emit_signal("onEntityAdded", self)


"""
Returns the spatial node which resembles this entity.
"""
func get_spatial():
	return get_parent()


"""
Returns the bounding box of the mesh of this entity. If not provided, then a 
unit sized cube is returned. This is needed as some parts need to know the size
of an entity when interacting with e.g. for displaying special effects.
"""
func get_aabb() -> AABB:
	return _aabb


"""
Returns the top position of an entity.
"""
func get_origin_top() -> Vector3:
	var origin = get_spatial().global_transform.origin
	var height = get_aabb().size.y
	origin.y += height
	
	return origin


func remove():
	emit_signal("removed")


func update_component(component):
	emit_signal("component_updated", component)


func remove_component(component_name: String):
	emit_signal("component_removed", component_name)


func use(player_entity) -> void:
	emit_signal("used", player_entity)


# The clicking should work like so:
# Select the object and see if there is a default behavior
# yes: - des the behavior need physical placement beside the object
# - yes -- Move towards object
# - no -- Execute behavior
# no: - Select the object and show all possible actions
func _on_ClickBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		GlobalEvents.emit_signal("onEntityClicked", self, event)


func _on_ClickBody_mouse_entered():
	GlobalEvents.emit_signal("onEntityMouseEntered", self)
	emit_signal("mouse_entered")


func _on_ClickBody_mouse_exited():
	GlobalEvents.emit_signal("onEntityMouseExited", self)
	emit_signal("mouse_exited")


func _on_Entity_tree_exiting():
	GlobalEvents.emit_signal("onEntityRemoved", self)
