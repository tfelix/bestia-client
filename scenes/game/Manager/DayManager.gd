extends Node

var PST = preload("res://PubSubTopics.gd")
var DayData = preload("res://scenes/Game/DayData.gd");

export(NodePath) var world_environment_path
export var enable: bool = true

var sunrise_duration = 1.0/24 * 3 # 3hrs
var current_daytime: DayData
var world_environment: WorldEnvironment

var color_sunrise = Color(0.870588, 0.694118, 1)
var color_day = Color(1, 1, 1)
var color_evening = Color(0.905882, 0.545098, 0.12549)
var color_night = Color(0, 0.007843, 0.470588)

# Called when the node enters the scene tree for the first time.
func _ready():
	world_environment = get_node(world_environment_path)

func process_daytime():
	var time = OS.get_time();
	var day_data = DayData.new()
	day_data.progress = (time.hour * 60 + time.minute) / (24.0 * 60)
	# print_debug("Current day progress: ", day_data.progress)
	current_daytime = day_data
	PubSub.publish(PST.ENV_DAYTIME_CHANGED, day_data)
	
	if !enable:
		return
	
	adjust_sun_position()
	adjust_sun_energy()
	adjust_sun_color()

func adjust_sun_position():
	var sun = $Sun as DirectionalLight
	# sun.rotate_object_local(Vector3.AXIS_Z, 0.2)

func adjust_sun_energy():
	var env = (world_environment.environment as Environment)
	var adjusted_sunset_start = current_daytime.sunset
	var adjusted_sunset_end = current_daytime.sunset + sunrise_duration
	var adjusted_sunrise_start = current_daytime.sunrise
	var adjusted_sunrise_end = current_daytime.sunrise + sunrise_duration
	
	if current_daytime.progress > adjusted_sunrise_end && current_daytime.progress < adjusted_sunset_start:
		# Day
		env.ambient_light_energy = 1
	elif current_daytime.progress >= adjusted_sunset_start && current_daytime.progress <= adjusted_sunset_end:
		# Sunset
		var progress = 1 - (current_daytime.progress - adjusted_sunset_start) / (adjusted_sunset_end - adjusted_sunset_start)
		var clamped_progress = clamp(progress, 0, 1)
		env.ambient_light_energy = clamped_progress
	# We need a special test to check for night condition as we have the day boundary
	elif current_daytime.progress < 1 && current_daytime.progress > adjusted_sunset_end || current_daytime.progress > 0 && current_daytime.progress < adjusted_sunrise_start:
		# Night
		env.ambient_light_energy = 0
	else:
		# Sunrise
		var progress = (current_daytime.progress - adjusted_sunrise_start) / (adjusted_sunrise_end - adjusted_sunrise_start)
		var clamped_progress = clamp(progress, 0, 1)
		env.ambient_light_energy = clamped_progress
	# print_debug("Ambient Light intensity: ", env.ambient_light_energy)

func adjust_sun_color():
	var env = (world_environment.environment as Environment)
	# FIXME This function is bullshit
	var blend_fac = clamp(-18.123 * pow(current_daytime.progress, 2) + 1.13, 0, 1)
	blend_fac = 0.9
	var sun_color: Color
	# TODO Add the blend to the night color
	if current_daytime.progress < 0.5:
		# Sunrise
		sun_color = color_sunrise.linear_interpolate(color_day, blend_fac)
	else:
		# Dawn
		sun_color = color_day.linear_interpolate(color_evening, blend_fac)
	env.ambient_light_color = sun_color
	# print_debug("Ambient color: ", sun_color)

func _on_Timer_timeout():
	process_daytime()
