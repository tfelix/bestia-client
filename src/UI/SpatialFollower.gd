"""
It will move its parent origin to the screen projected
place of the connected spatial node. 
"""
extends Node
class_name SpatialFollower


export(NodePath) var follow_node
export(bool) var enabled = false

var _follow_node
var _camera


func _ready():
	_follow_node = find_node(follow_node)


func _process(delta):
	if not enabled:
		return
	
	if not _camera:
		_camera = get_tree().get_root().get_camera()
	# Camera might be null if we get it too early
	if not _camera:
		return
	
	if not _follow_node:
		_follow_node = get_node(follow_node)
	
	if not _follow_node:
		return
	
	var pos = _follow_node.global_transform.origin
	var cam_pos = _camera.unproject_position(pos)
	get_parent().rect_position = cam_pos
