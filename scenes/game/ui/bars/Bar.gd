extends TextureProgress

# Called when the node enters the scene tree for the first time.
func _ready():
	_update_position()

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
