extends VBoxContainer
class_name AttackRow

signal pressed

export(bool) var selected = false

onready var _atk_name = $MarginContainer/AttackWrapper/AttackText/AttackName as Label
onready var _atk_element = $MarginContainer/AttackWrapper/AttackText/AttackElement
onready var _mana = $MarginContainer/AttackWrapper/MarginMana/Mana
onready var _lv = $MarginContainer/AttackWrapper/Lv

var attack: Attack


func set_attack(atk: Attack) -> void:
	_atk_name.text = atk.name
	_atk_element.text = atk.element
	_mana.text = String(atk.mana)
	_lv.text = "Lv. " + String(atk.level)
	attack = atk


func _on_AttackRow_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
			get_tree().set_input_as_handled()
			emit_signal("pressed", self)
