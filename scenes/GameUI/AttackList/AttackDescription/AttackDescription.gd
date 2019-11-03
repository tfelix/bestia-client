extends Panel

onready var _title = $BorderMargin/AttackDescription/Title/Title
onready var _desc = $BorderMargin/AttackDescription/Description
onready var _audio_click = $AudioClick

func _ready():
	var atk2 = Attack.new()
	atk2.attack_entity_id = 1
	atk2.attack_id = 2
	atk2.db_name = "fireball"
	atk2.element = "FIRE"
	atk2.mana = 5
	atk2.level = 2
	atk2.name = tr(atk2.db_name)
	atk2.description = tr(atk2.db_name + "_desc")
	set_attack(atk2)


func set_attack(atk: Attack):
	_title.text = atk.name
	_desc.text = atk.description


func _on_Close_pressed():
	_audio_click.play()
	

# We must wait until the sound is finished otherwise the sound wont be played
func _on_AudioClick_finished():
	queue_free()
