extends WorldEnvironment

export var enable: bool = true

onready var sun = $WorldEnvironment/Sun as DirectionalLight

const sunrise_duration = 1.0/24 * 3 # 3hrs

var day_data: DayData
var weather_data: WeatherData

var color_sunrise = Color(0.870588, 0.694118, 1)
var color_day = Color(1, 1, 1)
var color_evening = Color(0.905882, 0.545098, 0.12549)
var color_night = Color(0, 0.007843, 0.470588)

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalEvents.connect("onWeatherChanged", self, "process_weather")
	GlobalEvents.connect("onDaytimeChanged", self, "process_daytime")


func process_weather(new_weather_data: WeatherData):
	weather_data = new_weather_data
	pass


func process_daytime(new_day_data: DayData):
	day_data = new_day_data
	
	if !enable:
		return
	
	# adjust_sun_position()
	# adjust_sun_energy()
	adjust_sun_color()


func adjust_sun_position():
	pass
	# sun.rotate_object_local(Vector3.AXIS_Z, 0.2)


func adjust_sun_energy():
	var env = environment as Environment
	var adjusted_sunset_start = day_data.sunset
	var adjusted_sunset_end = day_data.sunset + sunrise_duration
	var adjusted_sunrise_start = day_data.sunrise
	var adjusted_sunrise_end = day_data.sunrise + sunrise_duration
	
	if day_data.progress > adjusted_sunrise_end && day_data.progress < adjusted_sunset_start:
		# Day
		env.ambient_light_energy = 1
	elif day_data.progress >= adjusted_sunset_start && day_data.progress <= adjusted_sunset_end:
		# Sunset
		var progress = 1 - (day_data.progress - adjusted_sunset_start) / (adjusted_sunset_end - adjusted_sunset_start)
		var clamped_progress = clamp(progress, 0, 1)
		env.ambient_light_energy = clamped_progress
	# We need a special test to check for night condition as we have the day boundary
	elif day_data.progress < 1 && day_data.progress > adjusted_sunset_end || day_data.progress > 0 && day_data.progress < adjusted_sunrise_start:
		# Night
		env.ambient_light_energy = 0
	else:
		# Sunrise
		var progress = (day_data.progress - adjusted_sunrise_start) / (adjusted_sunrise_end - adjusted_sunrise_start)
		var clamped_progress = clamp(progress, 0, 1)
		env.ambient_light_energy = clamped_progress
	
	if weather_data:
		env.ambient_light_energy *= weather_data.light_intensity / 100.0

func adjust_sun_color():
	var env = environment as Environment
	var sun_color: Color
	if day_data.progress < 0.5:
		# Sunrise into Day
		var weight = smoothstep(0.0, 1.0, (1.0 / sunrise_duration) * (day_data.progress - day_data.sunrise))
		sun_color = color_sunrise.linear_interpolate(color_day, weight)
	else:
		# Day into Dawn
		var weight = smoothstep(0.0, 1.0, (1.0 / sunrise_duration) * (day_data.progress - day_data.sunset))
		sun_color = color_day.linear_interpolate(color_evening, weight)
	env.ambient_light_color = sun_color

