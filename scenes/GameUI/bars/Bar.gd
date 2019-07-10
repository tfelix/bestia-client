extends Control

var duration_ms: int = 1000
var can_user_cancel: bool = false
var can_move: bool = false

const _base_animation_duration = 5000.0

func _ready():
	_update_position()
	
func _adapt_speed():
	var fac = duration_ms / _base_animation_duration
	$AnimationPlayer.playback_speed = fac

func _update_position():
	var parent = get_parent()
	var camera = get_tree().get_root().get_camera()
	
	var offset = Vector2(get_size().x / 2, 0)
	var node_height = Vector3(0, 3, 0)
	var pos = camera.unproject_position(parent.get_translation() + node_height) - offset
	set_position(pos)

func _on_AnimationPlayer_animation_finished(anim_name):
	if(anim_name != "ProgressBar"):
		pass
	queue_free()
