extends Camera

# Camera movement and control
const camera_start_position = Vector3(0.0, 3.8, 5.3)

var camera_zoom_increment = 0.2
var zoomlevel = 10

var current_rotation = 0
var is_cam_move_enabled = false

export var max_zoomlevel = 20
export var min_zoomlevel = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	translation = camera_start_position.normalized() * camera_start_position.length() * camera_zoom_increment * zoomlevel

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_WHEEL_UP:
				_zoom_in()
			elif event.button_index == BUTTON_WHEEL_DOWN:
				_zoom_out()
			elif event.button_index == BUTTON_RIGHT:
				is_cam_move_enabled = true
		else:
			is_cam_move_enabled = false
	elif event is InputEventMouseMotion:
		if !is_cam_move_enabled:
			return
		_rotate_cam()
		print("Mouse Motion at: ", event.position, "enabled: ", is_cam_move_enabled)

func _rotate_cam():
	current_rotation += 0.01
	var current_pos = camera_start_position.normalized() * camera_start_position.length() * camera_zoom_increment * zoomlevel
	translation = current_pos.rotated(Vector3.LEFT, current_rotation)
	#rotation_degrees = Vector3(0, rotation_degrees.y + 1, 0)
	pass

func _zoom_in():
	zoomlevel -= 1
	if zoomlevel < min_zoomlevel:
		zoomlevel = min_zoomlevel
	translation = camera_start_position.normalized() * camera_start_position.length() * camera_zoom_increment * zoomlevel
	
func _zoom_out():
	zoomlevel += 1
	if zoomlevel > max_zoomlevel:
		zoomlevel = max_zoomlevel
	translation = camera_start_position.normalized() * camera_start_position.length() * camera_zoom_increment * zoomlevel