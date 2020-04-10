extends Component
class_name VisualComponent

const NAME = "VisualComponent"

"""
This is the visual identifier and determines which model is getting spawned
when this entity is encountered.
"""
var visual: String
var animation: String

var _animation_player

func get_name() -> String:
	return NAME


# Called if the component is attached to an Entity
func on_attach(entity, data: ComponentData) -> void:
	_animation_player = entity.get_parent().get_node("AnimationPlayer")


func on_update(entity, component_data: ComponentData) -> void:
	animation = component_data.data["animation"]
	_animation_player.play(animation)
