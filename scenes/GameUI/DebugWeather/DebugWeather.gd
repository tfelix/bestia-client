extends PanelContainer

# var DayData = preload("res://scenes/Game/DayData.gd")

onready var day = $Rows/DaySlider/DaySlider
onready var brightness = $Rows/BrigthnessSlider/BrightnessSlider
onready var weather = $Rows/Weather/WeatherSlider


func _send_weather_data():
	var env_data = WeatherData.new()
	env_data.light_intensity = int(brightness.value)
	env_data.rain_intensity = int(100 - weather.value)
	PubSub.publish(PST.ENV_WEATHER_CHANGED, env_data)
	
	var day_data = DayData.new()
	day_data.progress = day.value / 100.0
	PubSub.publish(PST.ENV_DAYTIME_CHANGED, day_data)

func _on_ResetButton_pressed():
	day.value = 50
	brightness.value = 50
	weather.value = 100
	_send_weather_data()

func _on_WeatherSlider_value_changed(value):
	_send_weather_data()

func _on_BrightnessSlider_value_changed(value):
	_send_weather_data()

func _on_DaySlider_value_changed(value):
	_send_weather_data()
