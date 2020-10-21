extends Spatial
class_name Mannequiny

const Hairstyles = preload("res://Player/Hair/Hairstyle.gd")

# Controls the animation tree's transitions for this animated character.

# # It has a signal connected to the player state machine, and uses the resulting
# state names to translate them into the states for the animation tree.

enum States {IDLE, RUN, AIR, LAND}

onready var _animation_tree: AnimationTree = $AnimationTree
onready var _playback: AnimationNodeStateMachinePlayback = _animation_tree["parameters/playback"]
onready var _hair = $root/Skeleton/Hair
onready var _skeleton = $root/Skeleton

var _haircolor: Color

func _ready() -> void:
	_animation_tree.active = true


func transition_to(state_id: int) -> void:
	match state_id:
		States.IDLE:
			_playback.travel("idle")
		States.LAND:
			_playback.travel("land")
		States.RUN:
			_playback.travel("move_ground")
		States.AIR:
			_playback.travel("jump")
		_:
			_playback.travel("idle")


func set_hairstyle(style) -> void:
	var scene_path = Hairstyles.HairstyleScene[style]
	
	if !scene_path:
		printerr("Did not find hairstyle for ", style)
		return
	
	var hair = load(scene_path).instance()
	
	if _hair:
		_hair.queue_free()
	
	_hair = hair
	_skeleton.add_child(hair)


func set_haircolor(color: Color) -> void:
	_haircolor = color
	_hair.set_haircolor(color)
