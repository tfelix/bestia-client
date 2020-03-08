extends Spatial

# The rain system improvements:
# - Better visual quality
# - React to wind direction
# - Adapt particle count via placement via shader
# For more info see https://seblagarde.wordpress.com/2012/12/27/water-drop-2a-dynamic-rain-and-its-effects/

onready var _rain = $RainDrops
onready var _rain_fx = $RainAudio
onready var _thunder_timer = $ThunderTimer

var _thunder = []
var _intensity = 0

export var max_rain_particles = 3000

func _ready() -> void:
	_rain.amount = max_rain_particles
	_rain.process_material.set_shader_param("max_number_particles", max_rain_particles)
	_rain.process_material.set_shader_param("number_particles_shown", 0)
	GlobalEvents.connect("onWeatherChanged", self, "handle_weather_changed")
	_thunder.push_back($Thunder1)
	_thunder.push_back($Thunder2)
	_thunder.push_back($Thunder3)
	_thunder.push_back($Thunder4)
	_thunder.push_back($Thunder5)


func handle_weather_changed(data) -> void:
	_intensity = data.rain_intensity / 100.0

	change_rain_amount(_intensity)
	change_loudness(_intensity)


func change_loudness(intensity: float) -> void:
	if intensity > 0:
		if !_rain_fx.playing:
			_rain_fx.play()
		var loudness = lerp(-35, 8, clamp(intensity, 0, 1.0))
		_rain_fx.volume_db = loudness
	else:
		_rain_fx.playing = false


func change_rain_amount(intensity: float) -> void:
	if intensity == 0:
		# Do this in a slower animation to avoid rough cutoff.
		_rain.emitting = false
	# Only activate if its not active, otherwise it restarts.
	if intensity > 0 && !_rain.emitting:
		_rain.emitting = true
	
	var num_particles = lerp(0, max_rain_particles, clamp(intensity, 0, 1.0))
	_rain.process_material.set_shader_param("number_particles_shown", num_particles)
	_setup_possible_thunder()


func _setup_possible_thunder() -> void:
	var thunder_delay = lerp(300, 15, clamp((_intensity - 0.5) * 2, 0, 1.0))
	
	# * (randi() % 30 + 100) / 100.0
	print_debug("Next thunder in ", thunder_delay)
	_thunder_timer.wait_time = thunder_delay
	_thunder_timer.start()


func _on_ThunderTimer_timeout() -> void:
	_setup_possible_thunder()
	var p_thunder = lerp(0, 1.0, clamp((_intensity - 0.5) * 2, 0, 1.0))
	print_debug("P Thunder: ", p_thunder)
	if randf() > p_thunder:
		return
	
	var volume = lerp(-20, 3, clamp((_intensity - 0.5) * 2.0, 0, 1.0)) + randf() * 4
	var i = randi() % _thunder.size()
	var thunder = _thunder[i] as AudioStreamPlayer
	thunder.volume_db = volume
	thunder.play()
