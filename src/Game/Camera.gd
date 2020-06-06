extends Camera

export var min_distance = 7
export var max_distance = 28

export var max_theta_delta = 30
export var max_phi_delta = 55

export var camera_move_distance = 0.3 # how many % of the viewport you must travel
export var camera_move_speed = 0.5 # camera does 

var _is_cam_controlled = false
var _start_theta = 0
onready var _r_tween = $DistanceTween

var _current_theta = 0
var _current_phi = 0

# These are here to avoid "jumps" when the user starts to
# move the camera again.
var _last_theta = 0
var _last_phi = 0

var _current_distance = (min_distance + max_distance) / 2
# Helper variable for easing the camera movement
var _r = 0
var _start_cam_move = Vector2()
var _cam_dir = Vector3()

var _distance_outside_building = min_distance
var _is_in_building = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_cam_dir = transform.origin.normalized()
	_current_theta = rad2deg(acos(_cam_dir.y)) # length is 1 unit vector
	_start_theta = _current_theta
	_last_theta = _start_theta
	set_as_toplevel(true)
	
	_current_phi = GlobalConfig.get_value("camera", "current_phi", 0)
	_current_theta = GlobalConfig.get_value("camera", "current_theta", _current_theta)
	_current_distance = GlobalConfig.get_value("camera", "current_distance", _current_distance)
	_r = _current_distance

	GlobalEvents.connect("onBuildingEntered", self, "_player_enters_building")
	GlobalEvents.connect("onBuildingExit", self, "_player_exists_building")


func _process(delta):
	var z = _r * sin(deg2rad(_current_theta)) * cos(deg2rad(_current_phi))
	var y = _r * cos(deg2rad(_current_theta))
	var x = _r * sin(deg2rad(_current_theta)) * sin(deg2rad(_current_phi))
	
	var parent_pos = get_parent().global_transform.origin
	var new_cam_pos = Vector3(parent_pos.x + x, parent_pos.y + y, parent_pos.z + z)
	# TODO Perform a smooth scrolling
	look_at_from_position(new_cam_pos, parent_pos, Vector3.UP)


"""
Starts camera movement towards the targeted distance _current_distance.
"""
func _start_easing_to_distance(_new_distance: float, duration: float = 1.0) -> void:
	_r_tween.interpolate_property(
		self, 
		"_r", 
		_r, 
		_new_distance,
		duration,
		Tween.TRANS_CUBIC,
		Tween.EASE_IN_OUT
	)
	_r_tween.start()
	_current_distance = _new_distance


func _player_enters_building(building_id: String) -> void:
	_distance_outside_building = _current_distance
	_start_easing_to_distance(min_distance + 2)
	_is_in_building = true


func _player_exists_building(building_id: String) -> void:
	_start_easing_to_distance(_distance_outside_building)
	_is_in_building = false


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				# No cam zoom inside buildings
				if _is_in_building:
					return
				_zoom_in()
			elif event.button_index == BUTTON_WHEEL_DOWN:
				# No cam zoom inside buildings
				if _is_in_building:
					return
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
	
	GlobalConfig.set_value("camera", "current_phi", _current_phi)
	GlobalConfig.set_value("camera", "current_theta", _current_theta)


func _reset() -> void:
	_current_phi = 0
	_current_theta = _start_theta
	GlobalConfig.set_value("camera", "current_phi", _current_phi)
	GlobalConfig.set_value("camera", "current_theta", _current_theta)


func _zoom_in() -> void:
	if _current_distance > min_distance:
		_start_easing_to_distance(_current_distance - 1, 0.2)
	else:
		_current_distance = min_distance
	GlobalConfig.set_value("camera", "current_distance", _current_distance)


func _zoom_out() -> void:
	if _current_distance < max_distance:
		_start_easing_to_distance(_current_distance + 1, 0.2)
	else:
		_current_distance = max_distance
	GlobalConfig.set_value("camera", "current_distance", _current_distance)
