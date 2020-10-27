extends Component
class_name VisualComponent

const NAME = "VisualComponent"

"""
This is the visual identifier and determines which model is getting spawned
when this entity is encountered.
"""
export var visual: String
export var animation: String

var _animation_player
var _current_vfx = null
var _postponed_animation = null

func get_name() -> String:
	return NAME


func on_attach(entity) -> void:
	entity.connect("vfx_played", self, "_vfx_played")
	_animation_player = entity.get_parent().get_node("AnimationPlayer")


func on_update(entity, component_data: ComponentData) -> void:
	animation = component_data.data["animation"]
	if _current_vfx != null:
		_postponed_animation = animation
	else:
		_animation_player.play(animation)


func _play_postponed_animation() -> void:
	if _postponed_animation != null:
		_animation_player.play(_postponed_animation)
		_postponed_animation = null


func _vfx_played(vfx_name) -> void:
	_current_vfx = vfx_name
	if _current_vfx == null:
		_play_postponed_animation()
