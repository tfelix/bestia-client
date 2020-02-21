extends Camera

export var min_distance = 7
export var max_distance = 28

export var min_theta = 25
export var max_theta = 70

export var min_phi = -45
export var max_phi = 45

export var camera_move_distance = 0.3 # how many % of the viewport you must travel

var _is_cam_controlled = false
var _r = 15
var _start_theta = 0
var _current_theta = 0
var _current_phi = 0

var _current_distance = (min_distance + max_distance) / 2
var _start_cam_move = Vector2()
var _cam_dir = Vector3()


# Called when the node enters the scene tree for the first time.
func _ready():
	_r = transform.origin.length()
	# parent is expected to be at 0,0,0
	_cam_dir = transform.origin.normalized()
	_current_theta = rad2deg(acos(_cam_dir.y)) # length is 1 unit vector
	_start_theta = _current_theta
	set_as_toplevel(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var z = _current_distance * sin(deg2rad(_current_theta)) * cos(deg2rad(_current_phi))
	var y = _current_distance * cos(deg2rad(_current_theta))
	var x = _current_distance * sin(deg2rad(_current_theta)) * sin(deg2rad(_current_phi))
	
	var parent_pos = get_parent().global_transform.origin
	look_at_from_position(Vector3(parent_pos.x + x, parent_pos.y + y, parent_pos.z + z), parent_pos, Vector3.UP)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				_zoom_in()
			elif event.button_index == BUTTON_WHEEL_DOWN:
				_zoom_out()
			elif event.button_index == BUTTON_RIGHT && event.doubleclick:
				_reset()
			elif event.button_index == BUTTON_RIGHT:
				_start_cam_move = event.position
				_is_cam_controlled = true
		else:
			_is_cam_controlled = false
	elif event is InputEventMouseMotion:
		if !_is_cam_controlled:
			return
		_prepare_rotation_cam(event)

func _prepare_rotation_cam(event):
	var size = get_viewport().get_visible_rect().size
	var d = min(size.x, size.y) * camera_move_distance
	var move_delta = (_start_cam_move - event.position)
	
	var rel_x = move_delta / d
	_current_theta -= move_delta.y
	_current_theta = clamp(_current_theta, min_theta, max_theta)
	
	_current_phi -= move_delta.x
	_current_phi = clamp(_current_phi, min_phi, max_phi)


func _reset():
	_current_phi = 0
	_current_theta = _start_theta


func _zoom_in():
	_current_distance -= 1
	if _current_distance < min_distance:
		_current_distance = min_distance


func _zoom_out():
	_current_distance += 1
	if _current_distance > max_distance:
		_current_distance = max_distance
