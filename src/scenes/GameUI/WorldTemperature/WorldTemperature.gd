extends HBoxContainer

const marker_offset = 4
const max_display_temp = 100
const min_display_temp = -40

onready var _marker = $TempBar/Marker
onready var _marker_high = $TempBar/MarkerHigh
onready var _marker_low = $TempBar/MarkerLow
onready var _wheel = $TempBar/TempWheel
onready var _temp_label = $TempLabel


func _ready():
	GlobalEvents.connect("onTemperatureChanged", self, "update_temp")


func update_temp(data: TemperatureData) -> void:
	_temp_label.text = "%d °C" % data.current_temp
	var px_per_kelvin = _wheel.rect_min_size.x / (abs(min_display_temp) + max_display_temp)
	
	var pos_min_px = (data.min_tolerable_temp + abs(min_display_temp)) * px_per_kelvin - marker_offset
	var pos_min = clamp(pos_min_px, 0, 100) - marker_offset
	_marker_low.rect_position = Vector2(pos_min, 16)
	
	var pos_max_px = (data.max_tolerable_temp + abs(min_display_temp)) * px_per_kelvin
	var pos_max = clamp(pos_max_px, 0, 100) - marker_offset
	_marker_high.rect_position = Vector2(pos_max, 16)
	
	var pos_marker_px = (data.current_temp + abs(min_display_temp)) * px_per_kelvin - marker_offset
	_marker.rect_position = Vector2(pos_marker_px, 15)
	