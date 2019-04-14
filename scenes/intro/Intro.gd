extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = 4
	$Timer.one_shot = true
	$Timer.connect("timeout", self, "timeout")
	$Timer.start()
	pass

func timeout():
	$FadeIn.fade()

func _on_FadeIn_fade_in_finished():
	# Here we must step to the next parts of the story.
	$Story.stop()

func _on_FadeIn_fade_out_finished():
	$Step3.hide()
	pass # Replace with function body.
