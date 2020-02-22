extends Entity
class_name Mob

onready var _local_components = $Components

func _ready():
	for lc in _local_components.get_children():
		lc.on_attach(self)


func _on_Collidor_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		GlobalEvents.emit_signal("onEntityClicked", self)
