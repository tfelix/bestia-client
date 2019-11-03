extends Control

var AttackRow = preload("res://scenes/GameUI/AttackList/AttackRow/AttackRow.tscn")
var AttackDescription = preload("res://scenes/GameUI/AttackList/AttackDescription/AttackDescription.tscn")

onready var _search_text = $CenterContainer/HBoxContainer/AttackPanel/BorderMargin/Attacks/Search/Search
onready var _attacks_container = $CenterContainer/HBoxContainer/AttackPanel/BorderMargin/Attacks/ScrollContainer/AttackRows
onready var _box_container = $CenterContainer/HBoxContainer
onready var _click_audio = $AudioClick

var _attack_description = null
var _attacks = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var atk1 = Attack.new()
	atk1.attack_entity_id = 1
	atk1.attack_id = 1
	atk1.db_name = "tackle"
	atk1.element = "NORMAL"
	atk1.mana = 2
	atk1.level = 1
	
	var atk2 = Attack.new()
	atk2.attack_entity_id = 1
	atk2.attack_id = 2
	atk2.db_name = "fireball"
	atk2.element = "FIRE"
	atk2.mana = 5
	atk2.level = 2
	
	var attacks = [atk1, atk2]
	_display_attacks(attacks)
	_render_filtered_attacks()


func _display_attacks(attacks) -> void:	
	_attacks = attacks

	for atk in _attacks:
		atk.name = tr(atk.db_name)
		atk.description = tr(atk.db_name + "_desc")

func _render_filtered_attacks() -> void:
	for c in _attacks_container.get_children():
		c.queue_free()
	
	var search_name = _search_text.text
	var displayed_attacks = []
	for atk in _attacks:
		atk.name = tr(atk.db_name)
		atk.description = tr(atk.db_name + "_desc")
		if search_name.empty() || atk.name.find(search_name) != -1:
			displayed_attacks.append(atk)
	
	for atk in displayed_attacks:
		var atk_row = AttackRow.instance()
		_attacks_container.add_child(atk_row)
		atk_row.set_attack(atk)
		atk_row.connect("pressed", self, "_attack_selected")


func open():
	_click_audio.play()
	visible = true


func close():
	_click_audio.play()
	visible = false


func _on_Close_pressed():
	close()


func _attack_selected(attack_row: AttackRow):
	for atk in _attacks_container.get_children():
		atk.selected = false
	attack_row.selected = true
	if _attack_description != null:
		_attack_description.queue_free()
	_attack_description = AttackDescription.instance()
	_box_container.add_child(_attack_description)
	var atk = attack_row.attack
	_attack_description.set_attack(atk)


func _on_ClearButton_pressed():
	_search_text.clear()
	_render_filtered_attacks()


func _on_Search_text_changed(new_text):
	_render_filtered_attacks()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close()