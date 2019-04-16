extends Camera

# Camera movement and control
const camera_start_position = Vector3(0.0, 6.5, 10)
const camera_zoom_increment = 0.2
const camera_move_speed = 0.3
const max_angle_delta_x_degree = 90
const max_angle_delta_y_degree = 25

var zoomlevel = 20

var current_rotation_x = 0
var current_rotation_y = 0

var delta_rot_x = 0
var delta_rot_y = 0

var start_cam_move = Vector2()
var is_cam_move_enabled = false

export var max_zoomlevel = 20
export var min_zoomlevel = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	_translate_cam()

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				_zoom_in()
			elif event.button_index == BUTTON_WHEEL_DOWN:
				_zoom_out()
			elif event.button_index == BUTTON_RIGHT:
				start_cam_move = event.position
				is_cam_move_enabled = true
		else:
			is_cam_move_enabled = false
	elif event is InputEventMouseMotion:
		if !is_cam_move_enabled:
			return
		_prepare_rotation_cam(event)
		_translate_cam()

func _prepare_rotation_cam(event: InputEventMouseMotion):
	var move_delta = event.position - start_cam_move
	start_cam_move = event.position
	delta_rot_x += move_delta.x * camera_move_speed
	delta_rot_y += move_delta.y * camera_move_speed
	
	if current_rotation_x > max_angle_delta_x_degree and delta_rot_x > 0:
		delta_rot_x = 0
	if current_rotation_x < -max_angle_delta_x_degree and delta_rot_x < 0:
		delta_rot_x = 0
	
	if current_rotation_y > max_angle_delta_y_degree and delta_rot_y > 0:
		delta_rot_y = 0
	if current_rotation_y < -10 and delta_rot_y < 0:
		delta_rot_y = 0

func _zoom_in():
	zoomlevel -= 1
	if zoomlevel < min_zoomlevel:
		zoomlevel = min_zoomlevel
	_translate_cam()
	
func _zoom_out():
	zoomlevel += 1
	if zoomlevel > max_zoomlevel:
		zoomlevel = max_zoomlevel
	_translate_cam()
	
func _translate_cam():
	var target = get_parent().translation
	var updated_translation_pos = camera_start_position * camera_zoom_increment * zoomlevel
	var updated_rotation_pos = updated_translation_pos.rotated(Vector3.UP, deg2rad(current_rotation_x + delta_rot_x))
	updated_rotation_pos = updated_rotation_pos.rotated(Vector3.LEFT, deg2rad(current_rotation_y + delta_rot_y))
	current_rotation_x += delta_rot_x
	current_rotation_y += delta_rot_y
	print("cur rot x: ", current_rotation_x)
	print("cur rot y: ", current_rotation_y)
	translation = updated_rotation_pos
	look_at(target, Vector3.UP)
	# Must reset delta to 0 to avoid cam movement when zooming
	delta_rot_x = 0
	delta_rot_y = 0
