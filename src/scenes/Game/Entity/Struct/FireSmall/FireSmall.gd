extends Spatial

onready var _flame = $Flame as MeshInstance

# The campfire will react upon weather changes and e.g. gets smaller
# or change direction if its windy.
func _ready() -> void:
	GlobalEvents.connect("onWeatherChanged", self, "_adapt_fire_to_weather")


func _adapt_fire_to_weather(weatherData: WeatherData) -> void:
	# TODO Improve fire scaling with weather
	if weatherData.rain_intensity < 10:
		_flame.visible = true
		_flame.scale = Vector3(2.0, 2.0, 1.0)
	elif weatherData.rain_intensity < 50:
		_flame.visible = true
		_flame.scale = Vector3(1.0, 1.0, 1.0)
	else:
		_flame.visible = false
