extends Control

func _on_Step1_finished():
	$AnimationPlayer.play("fade_step_1")
	$Step2.start()
	
func _on_Step2_finished():
	$AnimationPlayer.play("fade_step_2")
	$Step3.start()
	
func _on_Step3_finished():
	$AnimationPlayer.play("fade_step_3")
	$Step4.start()
	
func _on_Step4_finished():
	$AnimationPlayer.play("fade_step_4")
	$Step5.start()

func _on_Step5_finished():
	$Step5.visible = false
	$Step6.start()
	
func _on_Step6_finished():
	$Step6.visible = false
	$Step7.start()
	
func _on_Step7_finished():
	$AnimationPlayer.play("fade_step_7")
	$Step8.start()
	
func _on_Step8_finished():
	_start_game()

func _start_game():
	get_tree().change_scene("res://scenes/game/Game.tscn")
	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			_start_game()

func _on_FadeIn_fade_out_finished():
	print_debug("Switch go game")
