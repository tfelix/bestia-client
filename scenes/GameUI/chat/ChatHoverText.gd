extends Control
class_name ChatHoverText

export(int) var display_time = 3

func _ready():
	$DestroyTimer.wait_time = display_time
	get_tree().get_root().connect("size_changed", self, "_update_position")
	_update_position()
	# Scan parent for other chat nodes and remove them.
	# for node in get_parent().get_children():
	#	if node != self and node is ChatHoverText:
	#		pass
			# node.queue_free() 

func set_text(text):
	$Text.text = text

func _update_position():
	var player = Global.player
	var label = $Text
	var camera = get_tree().get_root().get_camera()
	
	var offset = Vector2(label.get_size().x / 2, 0)
	var node_height = Vector3(0, 2, 0)
	var pos = camera.unproject_position(player.get_translation() + node_height) - offset
	label.set_position(pos)

func _on_DestroyTimer_timeout():
	queue_free()
