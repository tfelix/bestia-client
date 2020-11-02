class_name EnvironmentComponent

var entity_id: int

var  rain_intensity = 0 # 0: no rain, 10: little rain, 50 moderate rain, 100+ storm, heavy rain
var light_intensity = 70 # 0: total darkness, 20: moonshine, 70-80: normal day, 100+ bright summer day
var wind = Vector2(3, 1)
var max_tolerable_temp = 46
var min_tolerable_temp = -10
var current_temp = 15
var sunrise = 0.20 # The usual sunrise is at 0.2
var sunset = 0.70 # The usual sunset is at 0.7
var day_progress = 1 # 0 Start of Day (00:00), 1 End of Day (23:59)
