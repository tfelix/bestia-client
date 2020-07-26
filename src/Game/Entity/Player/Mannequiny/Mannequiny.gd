extends Spatial
class_name Mannequiny
# Controls the animation tree's transitions for this animated character.

# # It has a signal connected to the player state machine, and uses the resulting
# state names to translate them into the states for the animation tree.

enum States {IDLE, RUN, AIR, LAND}

onready var animation_tree: AnimationTree = $AnimationTree
onready var _playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]


func _ready() -> void:
	animation_tree.active = true


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
