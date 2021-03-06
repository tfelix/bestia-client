extends Panel

onready var _title = $BorderMargin/AttackDescription/Title/Title
onready var _desc = $BorderMargin/AttackDescription/Description
onready var _audio_click = $AudioClick


func set_attack(atk: AttackData):
	_title.text = atk.tr_name
	_desc.text = atk.tr_description


func _on_Close_pressed():
	_audio_click.play()
	

# We must wait until the sound is finished otherwise the sound wont be played
func _on_AudioClick_finished():
	queue_free()
