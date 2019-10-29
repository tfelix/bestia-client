extends Spatial

onready var _ray_up = $RayCastToUp
onready var _ray_cam = $RayCastToCam

export(NodePath) var camNode

var _hidden_objects = []
var _objects_to_hide = []

func _process(delta):
	var objects_to_show = []
	for o in _hidden_objects:
		if !_objects_to_hide.has(o):
			objects_to_show.append(o)
	
	_hide_objects(_objects_to_hide)
	_show_objects(objects_to_show)


func _hide_objects(objects_to_hide) -> void:
	for o in objects_to_hide:
		(o as Spatial).visible = false
	_hidden_objects = objects_to_hide


func _show_objects(objects_to_show) -> void:
	for o in objects_to_show:
		(o as Spatial).visible = true


func _physics_process(delta):
	_objects_to_hide = []
	_hideObjectsAbove()
	_adaptRayToCam()


func _hideObjectsAbove():
	while _ray_up.is_colliding():
		var above_obj = _ray_up.get_collider()
		_objects_to_hide.append(above_obj)
		_ray_up.add_exception(above_obj)
		_ray_up.force_raycast_update()
	
	
func _hideObjectsToCam():
	pass


func _adaptRayToCam():
	pass