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

const Damage3D = preload("res://scenes/Game/Damage/Damage3D.tscn")

export (EntityKind) var entity_kind = EntityKind.ITEM
export var id = 0


onready var _interactions = $Interactions
onready var _components = $Components

var _is_selected = false


func _ready():
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
Returns the bounding box of the mesh of this entity. Then a unit sized
cube is returned.
"""
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3.ONE)


func handle_message(msg):
	if msg is DamageMessage:
		_display_damage(msg)
	if msg is FxMessage:
		_display_fx(msg)
	if msg is Component:
		_components.update_component(msg)
	if msg is ComponentRemoveMessage:
		_components.remove_component(msg.component_name)


func _display_fx(msg: FxMessage) -> void:
	var path = "res://scenes/Attack/%s/%s.tscn" % ["Fireball", "Fireball"]
	var fx = load(path)
	print_debug("Calls FX ", msg.fx)


func _display_damage(msg: DamageMessage) -> void:
	var entity = GlobalData.entities.get_entity(msg.entity_id)
	if entity == null:
		print_debug("Entity ", msg.entity_id, " for DamageMessage not found")
		return
	var dmg3d = Damage3D.instance()
	dmg3d.init(msg, entity)
	add_child(dmg3d)


func get_component(component_name: String) -> Component:
	return _components.get_component(component_name)


func update_component(component: Component):
	return _components.update_component(component)

func remove_component(component_name: String):
	_components.remove_component(component_name)


# The clicking should work like so:
# Select the object and see if there is a default behavior
# yes: - des the behavior need physical placement beside the object
# - yes -- Move towards object
# - no -- Execute behavior
# no: - Select the object and show all possible actions
func _on_Collidor_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		_handle_default_input()
		GlobalEvents.emit_signal("onEntityClicked", self, event)
	if event.is_action_pressed(Actions.ACTION_RIGHT_CLICK):
		_handle_secondary_input()


func _handle_default_input() -> void:
	if _is_selected:
		_interactions.abort_interaction()
	else:
		if _interactions.has_default_interaction(self):
			_interactions.trigger_interaction(self)
		else:
			_interactions.show_possible_interactions()


func _handle_secondary_input():
	if _is_selected:
		_interactions.abort_interaction()
	else:
		_interactions.show_possible_interactions()


func _on_Collidor_mouse_entered():
	_components.on_mouse_entered(self)
	GlobalEvents.emit_signal("onEntityMouseEntered", self)


func _on_Collidor_mouse_exited():
	_components.on_mouse_exited(self)
	GlobalEvents.emit_signal("onEntityMouseExited", self)
