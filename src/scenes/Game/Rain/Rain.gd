extends Spatial

# The rain system improvements:
# - Better visual quality
# - React to wind direction
# - Adapt particle count via placement via shader

var splash_obj = preload("./RainSplash.tscn")

export var splash_area = 40
export var max_splashes_per_second = 600
export var splash_pool_size = 600

var splashes = []

var splashes_per_second = 0
var time_since_splash = 0
var splash_rate = INF
var cur_splash_ind = 0

var rain_drops: Particles
var maximum_raindrop_count = 0

func _ready():
	rain_drops = $RainDrops
	maximum_raindrop_count = rain_drops.amount
	GlobalEvents.connect("onWeatherChanged", self, "handle_weather_changed")

	for i in range(splash_pool_size):
		var s = splash_obj.instance()
		add_child(s)
		splashes.append(s)

func handle_weather_changed(data):
	print_debug("Rain intensity: ", data.rain_intensity)
	var intensity_norm = data.rain_intensity / 100.0

	change_rain_amount(intensity_norm)
	change_loudness(intensity_norm)


func change_loudness(intensity: float):
	if intensity > 0:
		if !$RainForrest.playing:
			$RainForrest.play()
		var loudness = lerp(-35, 0, clamp(intensity, 0, 1.0))
		$RainForrest.volume_db = loudness
	else:
		$RainForrest.playing = false


func change_rain_amount(intensity: float):
	if intensity > 0 && !rain_drops.emitting:
		# This is here so we dont call it again after and thus would reset
		# the emission.
		if !rain_drops.emitting:
			rain_drops.emitting = true

	if intensity <= 0:
		splashes_per_second = 0
		rain_drops.emitting = false

	splashes_per_second = lerp(0, max_splashes_per_second, clamp(intensity, 0, 1.0))
	if splashes_per_second == 0:
		splash_rate = INF
	else:
		splash_rate = 1.0 / splashes_per_second

	# https://github.com/godotengine/godot/issues/16352
	# For now this is disabled as its effectively restarting the
	# simulation. maybe we need a workaround for this as I am not sure it will get fixed
	# soon.
	# rain_drops.amount = int(maximum_raindrop_count * intensity)


func _physics_process(delta):
	time_since_splash += delta
	while time_since_splash >= splash_rate:
		make_splash()
		cur_splash_ind += 1
		cur_splash_ind %= splashes.size()
		time_since_splash -= splash_rate


func make_splash():
	var x_pos = rand_range(-splash_area, splash_area)
	var z_pos = rand_range(-splash_area, splash_area)
	var start_pos = global_transform.origin + Vector3(x_pos, 0, z_pos)

	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(start_pos, start_pos - Vector3(0, 100, 0))
	if result.size() > 0:
		splashes[cur_splash_ind].global_transform.origin = result.position + Vector3(0, 0.2, 0)
		splashes[cur_splash_ind].play()
