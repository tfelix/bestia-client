extends MeshInstance

var Actions = load("res://Actions.gd")

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if !event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		return
		
	print_debug("Terrain was clicked")
