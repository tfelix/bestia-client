extends Spatial

# The rain system improvements:
# - Better visual quality
# - React to wind direction
# - Adapt particle count via placement via shader
# For more info see https://seblagarde.wordpress.com/2012/12/27/water-drop-2a-dynamic-rain-and-its-effects/

onready var _rain = $RainDrops
onready var _rain_fx = $RainAudio

export var max_rain_particles = 3000

func _ready():
	_rain.amount = max_rain_particles
	_rain.process_material.set_shader_param("max_number_particles", max_rain_particles)
	_rain.process_material.set_shader_param("number_particles_shown", 0)
	GlobalEvents.connect("onWeatherChanged", self, "handle_weather_changed")


func handle_weather_changed(data):
	print_debug("Rain intensity: ", data.rain_intensity)
	var intensity_norm = data.rain_intensity / 100.0

	change_rain_amount(intensity_norm)
	change_loudness(intensity_norm)


func change_loudness(intensity: float):
	if intensity > 0:
		if !_rain_fx.playing:
			_rain_fx.play()
		var loudness = lerp(-35, 8, clamp(intensity, 0, 1.0))
		_rain_fx.volume_db = loudness
		print_debug("Rain Loudness to ", loudness)
	else:
		_rain_fx.playing = false


func change_rain_amount(intensity: float):
	if intensity == 0:
		# Do this in a slower animation to avoid rough cutoff.
		_rain.emitting = false
	# Only activate if its not active, otherwise it restarts.
	if intensity > 0 && !_rain.emitting:
		_rain.emitting = true
	
	var num_particles = lerp(0, max_rain_particles, clamp(intensity, 0, 1.0))
	_rain.process_material.set_shader_param("number_particles_shown", num_particles)
