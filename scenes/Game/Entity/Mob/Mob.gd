extends Entity
class_name Mob

func _on_Collidor_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		PubSub.publish(PST.ENTITY_CLICKED, self)
