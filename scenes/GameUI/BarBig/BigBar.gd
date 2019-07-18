extends Control

export (Color) var bar_color = Color.blue
export (Color) var update_bar_color = Color.white

onready var bar_over = $BarOver
onready var bar_under = $BarUnder
onready var update_tween = $UpdateTween

var _max_value = 100

func _ready():
	bar_over.tint_progress = bar_color
	bar_under.tint_progress = update_bar_color
	
func update_values(cur_value, max_value):
	_max_value = max_value
	var value_perc = 100.0 * cur_value / _max_value
	bar_over.value = value_perc
	update_tween.interpolate_property(bar_under, "value", bar_under.value, value_perc, 0.4, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	update_tween.start()
