extends HBoxContainer

onready var _temp_label = $TempLabel

func _ready():
	GlobalEvents.connect("onTemperatureChanged", self, "update_temp")


func update_temp(data: TemperatureData) -> void:
	_temp_label.text = "%d °C" % data.current_temp
	
