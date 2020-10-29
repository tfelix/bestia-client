"""
It will move its parent origin to the screen projected
place of the connected spatial node. 
"""
extends Control
class_name SpatialFollower


export(NodePath) var follow_node
export(bool) var enabled = true

var _follow_node


func _ready():
	yield(owner, "ready")
	_follow_node = get_node(follow_node)


func _process(delta):
	if not enabled:
		return
	
	if not _follow_node:
		return
	
	var camera = get_tree().get_root().get_camera()
	if camera == null:
		return
	
	var pos = _follow_node.global_transform.origin
	rect_position = camera.unproject_position(pos)
