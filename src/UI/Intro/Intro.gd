extends Control

onready var _scene_fade_in = $SceneFadeIn

const _game_scene = "res://tests/WalkTest/WalkTest.tscn"

onready var _anim_player = $AnimationPlayer
onready var _step0 = $Step0
onready var _step1 = $Step1
onready var _step2 = $Step2
onready var _step3 = $Step3
onready var _step4 = $Step4
onready var _step5 = $Step5
onready var _step6 = $Step6
onready var _step7 = $Step7
onready var _step8 = $Step8


func _ready():
	#_check_intro_skip()
	GlobalAudio.stop()
	_scene_fade_in.fade()
	yield(_scene_fade_in, "fade_in_finished")
	_step0.start()


func _check_intro_skip() -> void:
	var has_played_intro = GlobalConfig.get_value(GlobalConfig.SEC_MISC, GlobalConfig.PROP_MISC_PLAYED_INTRO, false)
	if has_played_intro:
		_start_game()
	else:
		GlobalConfig.set_value(GlobalConfig.SEC_MISC, GlobalConfig.PROP_MISC_PLAYED_INTRO, true)


func _on_Step0_finished():
	_anim_player.play("fade_step_0")
	yield(_anim_player, "animation_finished")
	_step1.start()


func _on_Step1_finished():
	_anim_player.play("fade_step_1")
	_step2.start()


func _on_Step2_finished():
	_anim_player.play("fade_step_2")
	$Step3.start()


func _on_Step3_finished():
	_anim_player.play("fade_step_3")
	$Step4.start()


func _on_Step4_finished():
	_anim_player.play("fade_step_4")
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
	get_tree().change_scene(_game_scene)


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			_start_game()


func _on_FadeIn_fade_out_finished():
	print_debug("Switch go game")
