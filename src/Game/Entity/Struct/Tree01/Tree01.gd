extends Spatial
class_name Tree01

onready var _entity = $Entity

func _on_Entity_used(player_entity):
	var req = InteractionRequest.new()
	req.entity_id = _entity.id
	req.interaction = "chop_tree"
	GlobalEvents.emit_signal("onMessageSend", req)
