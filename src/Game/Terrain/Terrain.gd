extends MeshInstance

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if !event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		return
	GlobalEvents.emit_signal("onTerrainClicked", click_position)
