extends Node
class_name Components


var _parent_entity


func _ready():
	_parent_entity = get_parent()
	for lc in get_children():
		# The parent is probably setting up children right now. The components
		# might as well setup childs, this will not work and we need to call
		# this deferred.
		lc.call_deferred("on_attach", _parent_entity)


func on_mouse_entered(entity) -> void:
	for c in get_children():
		c.on_mouse_entered(self)


func on_mouse_exited(entity) -> void:
	for c in get_children():
		c.on_mouse_exited(self)


func get_component(component_name: String) -> Component:
	for c in get_children():
		if c.get_name() == component_name:
			return c
	return null


func update_component(data: ComponentData) -> void:
	var old_comp: Component = null
	var pos = -1
	for c in get_children():
		pos += 1
		if c.get_name() == data.component_name:
			old_comp = c
			break

	if old_comp != null:
		old_comp.on_update(_parent_entity, data)
	else:
		var new_component = _spawn_component(data)
		new_component.on_attach(_parent_entity)
		new_component.on_update(_parent_entity, data)


func remove_component(componentName: String):
	var old_comp: Component = null
	var pos = 0
	for c in get_children():
		if c.get_name() == componentName:
			old_comp = c
			break
		pos += 1
	if old_comp != null:
		old_comp.on_remove(_parent_entity)
		remove_child(old_comp)


func _spawn_component(data: ComponentData) -> Component:
	var path = "res://Game/Entity/Component/%s.gd" % data.component_name
	var new_component = load(path).new()
	add_child(new_component)
	return new_component
