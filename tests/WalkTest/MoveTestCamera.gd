extends Camera

export var min_distance = 7
export var max_distance = 28

export var max_theta_delta = 30
export var max_phi_delta = 55

export var camera_move_distance = 0.3 # how many % of the viewport you must travel

var _is_cam_controlled = false
var _r = 15
var _start_theta = 0

var _current_theta = 0
var _current_phi = 0

# These are here to avoid "jumps" when the user starts to
# move the camera again.
var _last_theta = 0
var _last_phi = 0

var _current_distance = (min_distance + max_distance) / 2
var _start_cam_move = Vector2()
var _cam_dir = Vector3()

var config_file = "user://bestia.cfg"

# Called when the node enters the scene tree for the first time.
func _ready():
	_r = transform.origin.length()
	# parent is expected to be at 0,0,0
	_cam_dir = transform.origin.normalized()
	_current_theta = rad2deg(acos(_cam_dir.y)) # length is 1 unit vector
	_start_theta = _current_theta
	_last_theta = _start_theta
	set_as_toplevel(true)
	
	var config = ConfigFile.new()
	var err = config.load(config_file)
	if err == OK: 
		# If not, something went wrong with the file loading
		# Look for the display/width pair, and default to 1024 if missing
		_current_phi = config.get_value("camera", "current_phi", 0)
		_current_theta = config.get_value("camera", "current_theta", 0)
		_current_distance = config.get_value("camera", "current_distance", _current_distance)


func free():
	var config = ConfigFile.new()
	var err = config.load(config_file)
	if err == OK: 
		config.set_value("camera", "current_phi", _current_phi)
		config.set_value("camera", "current_theta", _current_theta)
		config.set_value("camera", "current_distance", _current_distance)
		config.save(config_file)
	.free()


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
			_stop_cam_motion()
	elif event is InputEventMouseMotion:
		if !_is_cam_controlled:
			return
		_rotate_cam(event)


func _stop_cam_motion() -> void:
	_last_phi = _current_phi
	_last_theta = _current_theta
	_is_cam_controlled = false


func _rotate_cam(event) -> void:
	var size = get_viewport().get_visible_rect().size
	var move_distance = min(size.x, size.y) * camera_move_distance
	var move_delta = (_start_cam_move - event.position)
	
	var rel_y = move_delta.y / move_distance
	_current_theta = clamp(_last_theta + rel_y * max_theta_delta, _start_theta - max_theta_delta, _start_theta + max_theta_delta)
	
	var rel_x = move_delta.x / move_distance
	_current_phi = clamp(_last_phi + rel_x * max_phi_delta, -max_phi_delta, max_phi_delta)


func _reset() -> void:
	_current_phi = 0
	_current_theta = _start_theta


func _zoom_in() -> void:
	_current_distance -= 1
	if _current_distance < min_distance:
		_current_distance = min_distance


func _zoom_out() -> void:
	_current_distance += 1
	if _current_distance > max_distance:
		_current_distance = max_distance
