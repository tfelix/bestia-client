extends HBoxContainer

onready var _text = $Clock


func _ready():
	PubSub.subscribe(PST.ENV_DAYTIME_CHANGED, self)


func free():
	PubSub.unsubscribe(self)
	.free()


func event_published(event_key, payload):
	match (event_key):
		PST.ENV_DAYTIME_CHANGED:
			_update_clock(payload)


func _update_clock(data: DayData) -> void:
	var day_progress = data.progress * 24
	var hours = int(day_progress)
	var minutes = (day_progress - hours) * 60
	_text.text = "%02d:%02d" % [hours, minutes]
