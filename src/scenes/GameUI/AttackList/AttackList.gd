extends Control

var AttackRow = preload("res://scenes/GameUI/AttackList/AttackRow/AttackRow.tscn")
var AttackDescription = preload("res://scenes/GameUI/AttackList/AttackDescription/AttackDescription.tscn")

onready var _search_text = $CenterContainer/HBoxContainer/AttackPanel/BorderMargin/Attacks/Search/Search
onready var _attacks_container = $CenterContainer/HBoxContainer/AttackPanel/BorderMargin/Attacks/ScrollContainer/AttackRows
onready var _box_container = $CenterContainer/HBoxContainer
onready var _click_audio = $AudioClick

var _attack_description = null
var _attacks = []

func _ready():
	GlobalEvents.connect("onMessageReceived", self, "_server_reveiced")
	_request_attack_list();
	_render_filtered_attacks()


func _server_reveiced(payload) -> void:
	if payload is ResponseAttackListMessage:
		_display_attacks(payload.attacks)


func _request_attack_list() -> void:
	var msg = RequestAttackListMessage.new()
	GlobalEvents.emit_signal("onMessageSend", msg)


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
		var _attack_description_ref = _attack_description.get_ref()
		if _attack_description_ref:
			_attack_description_ref.queue_free()
	
	_attack_description = weakref(AttackDescription.instance())
	_box_container.add_child(_attack_description.get_ref())
	
	var atk = attack_row.attack
	_attack_description.get_ref().set_attack(atk)


func _on_ClearButton_pressed():
	_search_text.clear()
	_render_filtered_attacks()


func _on_Search_text_changed(new_text):
	_render_filtered_attacks()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		close()


func _on_AttackList_visibility_changed():
	if visible == true:
		_request_attack_list();


func _on_AttackList_mouse_entered():
	GlobalEvents.emit_signal("onUiEntered")


func _on_AttackList_mouse_exited():
	GlobalEvents.emit_signal("onUiExited")
