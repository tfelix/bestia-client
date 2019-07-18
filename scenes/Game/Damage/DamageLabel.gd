extends Control

onready var label_normal = $DamageLabel
onready var label_heal = $HealLabel
onready var label_crit = $CritDamageLabel

func show_normal():
	label_normal.show()
	label_crit.hide()
	label_heal.hide()
	
func show_heal():
	label_heal.show()
	label_crit.hide()
	label_normal.hide()
	
func show_crit():
	label_crit.show()
	label_heal.hide()
	label_normal.hide()

func set_text(text: String):
	label_crit.text = text
	label_heal.text = text
	label_normal.text = text