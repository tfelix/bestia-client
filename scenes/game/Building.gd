extends Spatial

func _on_Area_body_entered(body):
	print_debug("player inside")
	for n in get_children():
		if n.name.begins_with("Roof"):
			print_debug(n)
			n.visible = false

func _on_Area_body_exited(body):
	print_debug("player exit")
	for n in get_children():
		if n.name.begins_with("Roof"):
			print_debug(n)
			n.visible = true
