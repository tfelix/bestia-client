extends HBoxContainer

onready var _text = $Clock


func _ready():
	GlobalEvents.connect("onDaytimeChanged", self, "_update_clock")


func _update_clock(data: DayData) -> void:
	var day_progress = data.progress * 24
	var hours = int(day_progress)
	var minutes = (day_progress - hours) * 60
	_text.text = "%02d:%02d" % [hours, minutes]
