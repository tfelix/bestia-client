extends Control

onready var _gender_button = $CenterContainer/DialogBackground/CharacterMargin/CharacterEditor/CharacterForm/TabContainer/Page1/GenderButton
onready var _character = $CenterContainer/DialogBackground/CharacterMargin/CharacterEditor/CharacterDisplay/Viewport/Mannequiny
onready var _tabs = $CenterContainer/DialogBackground/CharacterMargin/CharacterEditor/CharacterForm/TabContainer
onready var _back_button = $CenterContainer/DialogBackground/CharacterMargin/CharacterEditor/CharacterForm/SwitchButtons/BackButton
onready var _next_button = $CenterContainer/DialogBackground/CharacterMargin/CharacterEditor/CharacterForm/SwitchButtons/NextButton
onready var _finish_button = $CenterContainer/DialogBackground/CharacterMargin/CharacterEditor/CharacterForm/SwitchButtons/FinishButton
onready var _cam_target = $CenterContainer/DialogBackground/CharacterMargin/CharacterEditor/CharacterDisplay/Viewport/CamTarget
onready var _hairstyle_button = $CenterContainer/DialogBackground/CharacterMargin/CharacterEditor/CharacterForm/TabContainer/Page2/HairstyleButton

export var bgm_music: AudioStream

var character_data = {
	"name": "",
	"gender": "male",
	"hair_style": "",
	"hair_color": ""
}

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalAudio.play_bgm(bgm_music)
	_gender_button.add_item("Male")
	_gender_button.add_item("Female")
	_gender_button.add_item("Neutral")
	_hairstyle_button.add_item("Hairstyle 1")


func _check_page() -> void:
	match _tabs.current_tab:
		0:
			_back_button.visible = false
			_cam_target.global_transform.origin = Vector3(0.0,1.0, 2.2)
		1:
			_back_button.visible = true
			_finish_button.visible = false
			_next_button.visible = true
			_cam_target.global_transform.origin = Vector3(0.0,1.75, 0.8)
		2:
			_finish_button.visible = true
			_next_button.visible = false
			_cam_target.global_transform.origin = Vector3(0.0,1.75, 0.8)
			
	


func _on_NextButton_pressed():
	_tabs.current_tab += 1
	_check_page()


func _on_HairColorPicker_color_selected(color: Color):
	_character.set_haircolor(color)


func _on_BackButton_pressed():
	_tabs.current_tab -= 1
	_check_page()
