"""
It will move its parent origin to the screen projected
place of the connected spatial node. 
"""
extends Node
class_name SpatialFollower


export(NodePath) var follow_node
export(bool) var enabled = true
export var offset: Vector2 = Vector2(0.0, 0.0)

var _follow_node
var _camera


func _ready():
	_follow_node = find_node(follow_node)
	yield(owner, "ready")
	_camera = get_tree().get_root().get_camera()


func _process(delta):
	if not enabled:
		return

	# Camera might be null if we get it too early
	if not _camera:
		return
	
	if not _follow_node:
		_follow_node = get_node(follow_node)
	
	if not _follow_node:
		return
	
	var pos = _follow_node.global_transform.origin
	var cam_pos = _camera.unproject_position(pos)
	get_parent().rect_position = cam_pos + offset
