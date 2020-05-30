extends Node
"""
Responds to the players request to handle interactions with
certain entities.
"""
class_name FakeInteractionHandler


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func check_interactions(msg: InteractionRequest) -> void:
	var entity = GlobalData.entities.get_entity(msg.entity_id)
	if entity == null:
		printerr("Entity ", msg.entity_id, " does not exist")
		return
	
	var visual_comp = entity.get_component(VisualComponent.NAME) as VisualComponent
	if visual_comp == null:
		printerr("Entity ", msg.entity_id, " has no visual comp")
		return
	
	var interactions = _get_interactions(visual_comp.visual)
	
	var response = InteractionResponse.new()
	response.interactions = interactions
	response.entity_id = msg.entity_id
	GlobalEvents.emit_signal("onMessageReceived", response)

func _get_interactions(visual: String) -> Array:
	match visual:
		"wooden_bed":
			return ["use"]
		_:
			return []
