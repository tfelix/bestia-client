extends Camera

# Camera movement and control
const camera_start_position = Vector3(0.0, 3.8, 5.3)
const camera_zoom_increment = 0.2
const camera_move_speed = 0.001

var zoomlevel = 20
var current_rotation_x = 0
var current_rotation_y = 0
var start_cam_move = Vector2()
var is_cam_move_enabled = false

export var max_zoomlevel = 20
export var min_zoomlevel = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	translation = camera_start_position.normalized() * camera_start_position.length() * camera_zoom_increment * zoomlevel

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
		_rotate_cam(event)

func _rotate_cam(event: InputEventMouseMotion):
	var move_delta = event.position - start_cam_move
	current_rotation_x += move_delta.x * camera_move_speed
	current_rotation_y += move_delta.y * camera_move_speed
	_translate_cam()

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
	# var updated_rotation_pos = camera_start_position.rotated(Vector3.UP, current_rotation_x)
	# print("updated_rotation_pos: ", updated_rotation_pos)
	var updated_translation_pos = camera_start_position * camera_zoom_increment * zoomlevel
	print("updated_translation_pos: ", updated_translation_pos)
	translation = updated_translation_pos
	#rotation_degrees = Vector3(0, rotation_degrees.y + 1, 0)
	# look_at_from_position(updated_rotation_pos, target, Vector3.UP)
