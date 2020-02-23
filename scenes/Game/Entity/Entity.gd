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
	VEGETATION
}

const Damage3D = preload("res://scenes/Game/Damage/Damage3D.tscn")

export (EntityKind) var entity_kind = EntityKind.ITEM

var id = 0

onready var _selection = $Selection
onready var _interactions = $Interactions
onready var _components = $Components


func _ready():
	PubSub.publish(PST.ENTITY_ADDED, self)


func free():
  PubSub.publish(PST.ENTITY_REMOVED, self)
  .free()

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
		_components.add_component(msg)
	if msg is ComponentRemoveMessage:
		_components.remove_component(msg.component_name)


func _display_fx(msg: FxMessage) -> void:
	var path = "res://scenes/Attack/%s/%s.tscn" % ["Fireball", "Fireball"]
	var fx = load(path)
	print_debug("Calls FX ", msg.fx)
	pass


func _display_damage(msg: DamageMessage) -> void:
	var entity = Global.entities.get_entity(msg.entity_id)
	if entity == null:
		print_debug("Entity ", msg.entity_id, " for DamageMessage not found")
		return
	var dmg3d = Damage3D.instance()
	dmg3d.init(msg, entity)
	add_child(dmg3d)


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
	if _selection.is_selected:
		_selection.unselected()
		_interactions.abort_interaction()
	else:
		if _interactions.has_default_interaction(self):
			_interactions.trigger_interaction(self)
		else:
			_interactions.show_possible_interactions()
			_selection.selected()


func _handle_secondary_input():
	if _selection.is_selected:
		_selection.unselected()
		_interactions.abort_interaction()
	else:
		_interactions.show_possible_interactions()
		_selection.selected()


func _on_Collidor_mouse_entered():
	_components.on_mouse_entered(self)
	GlobalEvents.emit_signal("onEntityMouseEntered", self)


func _on_Collidor_mouse_exited():
	_components.on_mouse_exited(self)
	GlobalEvents.emit_signal("onEntityMouseExited", self)
