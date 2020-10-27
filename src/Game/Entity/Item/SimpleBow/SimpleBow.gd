extends Item


func _on_Entity_removed():
	queue_free()
