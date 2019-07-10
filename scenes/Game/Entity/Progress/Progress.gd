extends Control

var duration_ms: int = 1000
var can_user_cancel: bool = false
var can_move: bool = false
signal progress_completed

const _base_animation_duration = 5000.0

func _ready():
	_update_position()
	_adapt_speed()

func _adapt_speed():
	var fac = _base_animation_duration / duration_ms
	$AnimationPlayer.playback_speed = fac
	$AnimationPlayer.play("Progress")

func _update_position():
	var parent = get_parent()
	var camera = get_tree().get_root().get_camera()

	var offset = Vector2(get_size().x / 2, 0)
	var node_height = Vector3(0, 3, 0)
	var pos = camera.unproject_position(parent.get_translation() + node_height) - offset
	set_position(pos)

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("progress_completed")
	queue_free()
