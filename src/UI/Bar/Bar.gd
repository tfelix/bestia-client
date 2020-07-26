extends ColorRect

export (Color) var primary_color: Color = Color.red
export (Color) var secondary_color: Color = Color.yellow

onready var _primary = $BarColorPrimary
onready var _secondary = $BarColorSecondary
onready var _update_tween = $UpdateTween

var _is_initial_value = true

func _ready():
	_primary.color = primary_color
	_secondary.color = secondary_color


func set_value(value: float):
	var new_size = self.rect_size.x * value
	_primary.rect_size.x = new_size
	
	if _is_initial_value:
		_is_initial_value = false
		_secondary.rect_size = Vector2(new_size, _secondary.rect_size.y)
	else:
		_update_tween.interpolate_property(_secondary, "rect_size", _secondary.rect_size, Vector2(new_size, _secondary.rect_size.y), 0.4, Tween.TRANS_SINE, 0.0)
		_update_tween.start()
