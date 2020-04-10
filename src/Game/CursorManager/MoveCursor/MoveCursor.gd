extends Spatial

onready var _timer = $Timer
onready var _arrow1 = $MoveCursorArrow1
onready var _arrow2 = $MoveCursorArrow2
onready var _arrow3 = $MoveCursorArrow3
onready var _arrow4 = $MoveCursorArrow4


func _ready():
	visible = false
	set_as_toplevel(true)


func play():
	_timer.stop()
	_arrow1.play()
	_arrow2.play()
	_arrow3.play()
	_arrow4.play()
	visible = true
	_timer.start()
	yield(_timer, "timeout")
	visible = false
