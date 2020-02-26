extends Component
class_name EnvironmentComponent

const NAME = "EnvironmentComponent"

var rain_intensity: int = 0 # 0: no rain, 10: little rain, 50 moderate rain, 100+ storm, heavy rain
var light_intensity: int = 70 # 0: total darkness, 20: moonshine, 70-80: normal day, 100+ bright summer day
var wind: Vector2 # wind direction (wind is flat on the ground) and strength. Length: 5 Breeze, 10: Heavy Wind, 15+: Storm
var max_tolerable_temp: int
var min_tolerable_temp: int
var current_temp: int
var sunrise: float = 0.20 # The usual sunrise is at 0.2
var sunset: float = 0.70 # The usual sunset is at 0.7
var day_progress: float = 1 # 0 Start of Day (00:00), 1 End of Day (23:59)


func get_name() -> String:
	return NAME


func on_update(entity, new_component) -> void:
	# We must only update the client display if this component matches the current
	# active player.
	var player_info_comp = entity.get_component(PlayerComponent.NAME)
	var active_comp = entity.get_component(ActivePlayerBestiaComponent.NAME)
	
	if player_info_comp == null || active_comp == null:
		return
	
	if player_info_comp.account_id != GlobalData.client_account_id:
		return
	
	var temp_data = TemperatureData.new()
	temp_data.current_temp = new_component.current_temp
	temp_data.max_tolerable_temp = new_component.max_tolerable_temp
	temp_data.min_tolerable_temp = new_component.min_tolerable_temp
	PubSub.publish(PST.ENV_TEMP_CHANGED, temp_data)
	
	var weather_data = WeatherData.new()
	weather_data.rain_intensity = new_component.rain_intensity
	weather_data.light_intensity = new_component.light_intensity
	weather_data.wind = new_component.wind
	PubSub.publish(PST.ENV_WEATHER_CHANGED, weather_data)
	
	var time_data = DayData.new()
	time_data.sunrise = sunrise
	time_data.sunset = sunset
	time_data.progress = day_progress
	PubSub.publish(PST.ENV_DAYTIME_CHANGED, time_data)
