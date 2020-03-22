extends Node

onready var _sprite = $Sky/Sprite

func _ready():
	GlobalEvents.connect("onWeatherChanged", self, "_adapt_weather")
	step_scb(80)


func _adapt_weather(weather_data: WeatherData) -> void:
	cov_scb(weather_data.light_intensity)
	pass


func cov_scb(value):
	# 0-1
	_sprite.material.set("shader_param/COVERAGE",float(value)/100)

func absb_scb(value):
	# 0 - 10
	_sprite.material.set("shader_param/ABSORPTION",float(value)/10)

func thick_scb(value):
	# 0 - 100
	_sprite.material.set("shader_param/THICKNESS",value)

func step_scb(value):
	# 0 - 100
	_sprite.material.set("shader_param/STEPS", value)
