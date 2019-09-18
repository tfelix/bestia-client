extends Node

export var enable: bool = true

# This is some mockup to check and test changing weather effects.
# Later this manager should hook into the network and listen to changed
# preparding the internal data struct and then sending them out to the
# engine components.
func process_weather() -> void:
	var weather_data = WeatherData.new()
	PubSub.publish(PST.ENV_WEATHER_CHANGED, weather_data)

