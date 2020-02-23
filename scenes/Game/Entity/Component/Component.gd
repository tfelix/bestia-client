# We must NOT reference entity in here as this would lead to a cyclic dep problem.
# GDScript is sadly very weak in here. Until https://github.com/godotengine/godot/issues/27136
# is solved we must avoid references to Entity in this class (as Entity relies on Component as well)
extends Node
class_name Component

var id
var entity_id
# Flag if the component is not send to the server upon change.
# It is used only for the local client.
var local_only: bool = false

# Called if the component is attached to an Entity
func on_attach(entity) -> void:
	pass


"""
Called if the server sends an component update to the entity.
"""
func on_update(entity, new_component) -> void:
	pass


# Called if the component is removed from an Entity
func on_remove(entity) -> void:
	pass


func on_mouse_entered(entity) -> void:
	pass


func on_mouse_exited(entity) -> void:
	pass


func get_name() -> String:
	printerr("get_name() was not overwritten in Component")
	return ""
