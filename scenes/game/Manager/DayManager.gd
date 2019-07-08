extends Node

var PST = preload("res://PubSubTopics.gd")
var DayData = preload("res://scenes/Game/DayData.gd");

export(NodePath) var world_environment_path

var sunrise_duration = 1.0/24 * 3 # 3hrs
var current_daytime: DayData
var world_environment: WorldEnvironment

var temp_minutes = 600

var color_sunrise = Vector3(222, 177, 255)
var color_day = Vector3(255, 255, 255)
var color_evening = Vector3(231, 139, 32)
var color_night = Vector3(0, 2, 120)

# Called when the node enters the scene tree for the first time.
func _ready():
	world_environment = get_node(world_environment_path)

func process_daytime():
	var time = OS.get_time();
	var day_data = DayData.new()
	# day_data.progress = (time.hour * 60 + time.minute) / (24.0 * 60)

	day_data.progress = temp_minutes / (24.0 * 60)
	print_debug("Current day progress: ", day_data.progress)
	current_daytime = day_data
	PubSub.publish(PST.ENV_DAYTIME_CHANGED, day_data)
	adjust_sun_position()
	adjust_sun_energy()

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
	print_debug("Ambient Light intensity: ", env.ambient_light_energy)

func adjust_sun_color():
	var blend_fac = clamp(-18.123 * pow(current_daytime.progress, 2) + 1.13, 0, 1)
	pass

func _on_Timer_timeout():
	process_daytime()
