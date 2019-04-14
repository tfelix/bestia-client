extends Camera

# Camera movement and control
var camera_start_position = Vector3(0.0, 8.6, 9.6)
var camera_zoom_increment = 0.4
var zoomlevel = 20
var max_zoomlevel = 35
var min_zoomlevel = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_start_position.normalized() * camera_zoom_increment * zoomlevel

#func _input(event):
#	if event is InputEventMouseButton:
#	    if event.is_pressed():
#	        if event.button_index == BUTTON_WHEEL_UP:
#	            _zoom_in()
#	        if event.button_index == BUTTON_WHEEL_DOWN:
#	             _zoom_out()
	
func _zoom_in():
	zoomlevel -= 1
	if zoomlevel < min_zoomlevel:
		zoomlevel = min_zoomlevel
	translation = camera_start_position.normalized() * camera_zoom_increment * zoomlevel
	
func _zoom_out():
	zoomlevel += 1
	if zoomlevel > max_zoomlevel:
		zoomlevel = max_zoomlevel
	translation = camera_start_position.normalized() * camera_zoom_increment * zoomlevel