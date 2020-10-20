extends Control

onready var _gender_button = $CharacterMargin/CharacterEditor/CharacterForm/GenderButton
onready var _cam_target = $CharacterMargin/CharacterEditor/CharacterDisplay/Viewport/CamTarget

# Called when the node enters the scene tree for the first time.
func _ready():
	_gender_button.add_item("Male")
	_gender_button.add_item("Female")
	_gender_button.add_item("Neutral")


func _on_NextButton_pressed():
	_cam_target.global_transform.origin = Vector3(-0.83, 0.32, 2.0)
