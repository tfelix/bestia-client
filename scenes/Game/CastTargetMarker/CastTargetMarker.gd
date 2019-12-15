extends Spatial
class_name CastTargetMarker

onready var _marker = $CastMarker

var _parent_entity: Entity

func init(parent_entity: Entity):
	_parent_entity = parent_entity
	_remove_castmarker_from_parent(parent_entity)
	
	parent_entity.add_child(self)
	
	var size = _parent_entity.get_aabb().get_longest_axis_size() * 2.0
	size = max(4.0, size)
	_marker.scale = Vector3(size, size, size)


# Must override so we can remove ourselve.
func get_class(): return "CastTargetMarker"


func _remove_castmarker_from_parent(parent: Entity) -> void:
	for c in parent.get_children():
		if c.get_class() == "CastTargetMarker":
			c.queue_free()
			return


func _on_KillTimer_timeout():
	queue_free()
