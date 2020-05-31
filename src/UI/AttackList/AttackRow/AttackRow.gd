extends VBoxContainer

const DragAttack = preload("res://UI/AttackList/DragAttack.tscn")

signal pressed

export(bool) var selected = false

onready var _atk_name = $MarginContainer/AttackWrapper/AttackText/AttackName as Label
onready var _atk_element = $MarginContainer/AttackWrapper/AttackText/AttackElement
onready var _mana = $MarginContainer/AttackWrapper/MarginMana/Mana
onready var _lv = $MarginContainer/AttackWrapper/Lv
onready var _icon = $MarginContainer/AttackWrapper/IconMargin/CenterContainer/Icon


var data: AttackData


func get_drag_data(position):
	var drag_attack = DragAttack.instance()
	drag_attack.data = data
	set_drag_preview(drag_attack)
	
	return data


func set_attack(atk: AttackData) -> void:
	_atk_name.text = atk.tr_name
	_atk_element.text = atk.element
	_mana.text = String(atk.mana)
	_lv.text = "Lv. " + String(atk.level)
	_icon.texture = atk.icon
	data = atk


func _on_AttackRow_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().set_input_as_handled()
		emit_signal("pressed", self)
