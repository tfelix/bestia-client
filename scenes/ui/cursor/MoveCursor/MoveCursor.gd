extends Spatial

func _ready():
	visible = false
	set_as_toplevel(true)
	pass

func play():
	$MoveCursorArrow1.play()
	$MoveCursorArrow2.play()
	$MoveCursorArrow3.play()
	$MoveCursorArrow4.play()
	visible = true
	$Timer.start()

func _on_Timer_timeout():
	visible = false
