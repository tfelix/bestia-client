extends Node

var PST = load("res://PubSubTopics.gd")
var weather_data = preload("res://scenes/game/weather/WeatherData.gd").new()
var counter = 0

# This is some mockup to check and test changing weather effects.
# Later this manager should hook into the network and listen to changed
# preparding the internal data struct and then sending them out to the
# engine components.

func _on_Timer_timeout():
	counter += 1
	var period = abs(sin(counter / 25.0))
	weather_data.rain_intensity = int(100 * period)
	PubSub.publish(PST.ENV_WEATHER_CHANGED, weather_data)
