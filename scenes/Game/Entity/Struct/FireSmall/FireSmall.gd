extends Spatial

onready var _flame = $Flame as MeshInstance

# The campfire will react upon weather changes and e.g. gets smaller
# or change direction if its windy.
func _ready() -> void:
	PubSub.subscribe(PST.ENV_WEATHER_CHANGED, self)

func free() -> void:
  PubSub.unsubscribe(self)
  .free()

func event_published(event_key, payload) -> void:
	match (event_key):
		PST.ENV_WEATHER_CHANGED:
			if payload is WeatherData:
				_adapt_fire_to_weather(payload)

func _adapt_fire_to_weather(weatherData: WeatherData) -> void:
	# Improve fire scaling with weather
	if weatherData.rain_intensity < 10:
		_flame.visible = true
		_flame.scale = Vector3(2.0, 2.0, 1.0)
	elif weatherData.rain_intensity < 50:
		_flame.visible = true
		_flame.scale = Vector3(1.0, 1.0, 1.0)
	else:
		_flame.visible = false
