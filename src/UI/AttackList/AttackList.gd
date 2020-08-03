extends HBoxContainer

const AttackRow = preload("res://UI/AttackList/AttackRow/AttackRow.tscn")
const AttackDescription = preload("res://UI/AttackList/AttackDescription/AttackDescription.tscn")

onready var _search_text = $AttackPanel/BorderMargin/Attacks/Search/Search
onready var _attacks_container = $AttackPanel/BorderMargin/Attacks/ScrollContainer/AttackRows

var _attack_db = AttackDatabase.new()

var _attack_description = null
var _attacks = []

var _is_dragged = false
var _mouse_offset = Vector2(0, 0)

func _ready():
	GlobalEvents.connect("onMessageReceived", self, "_server_reveiced")
	GlobalEvents.connect("onShortcutPressed", self, "_shortcut_pressed")
	_request_attack_list();
	_render_filtered_attacks()
	# Setup the initial position
	var win_pos = GlobalConfig.get_value(GlobalConfig.SEC_WIN_POS, GlobalConfig.PROP_WIN_ATTACKS, Vector2(100, 100))
	rect_position = win_pos


func _process(delta):
	if _is_dragged:
		var mouse_pos = get_viewport().get_mouse_position()
		rect_position = mouse_pos - _mouse_offset


func can_drop_data(position, drop_data) -> bool:
	return false


func _shortcut_pressed(action_name: String, shortcut: ShortcutData) -> void:
	if not shortcut.type == ShortcutData.ShortcutType.ATTACK:
		return
	var player_attack_id = shortcut.payload["player_attack_id"]
	GlobalEvents.emit_signal("onCastSelectionStarted", player_attack_id)


func _server_reveiced(payload) -> void:
	if payload is ResponseAttackListMessage:
		_display_attacks(payload.attacks)


func _request_attack_list() -> void:
	var msg = RequestAttackListMessage.new()
	GlobalEvents.emit_signal("onMessageSend", msg)


func _display_attacks(attacks) -> void:
	var attacks_data = [] 
	for atk in attacks:
		var atk_data = _attack_db.get_data(atk)
		attacks_data.append(atk_data)
	_attacks = attacks_data


func _render_filtered_attacks() -> void:
	for c in _attacks_container.get_children():
		c.queue_free()
	
	var search_name = _search_text.text
	var displayed_attacks = []
	for atk in _attacks:
		if search_name.empty() || atk.tr_name.findn(search_name) != -1:
			displayed_attacks.append(atk)
	
	for atk in displayed_attacks:
		var atk_row = AttackRow.instance()
		_attacks_container.add_child(atk_row)
		atk_row.set_attack(atk)
		atk_row.connect("pressed", self, "_attack_selected")


func _attack_selected(attack_row):
	for atk in _attacks_container.get_children():
		atk.selected = false
	attack_row.selected = true
	
	if _attack_description != null:
		var _attack_description_ref = _attack_description.get_ref()
		if _attack_description_ref:
			_attack_description_ref.queue_free()
	
	_attack_description = weakref(AttackDescription.instance())
	add_child(_attack_description.get_ref())
	
	var atk = attack_row.data
	_attack_description.get_ref().set_attack(atk)


func _on_ClearButton_pressed():
	_search_text.clear()
	_render_filtered_attacks()


func _on_Search_text_changed(new_text):
	_render_filtered_attacks()


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_attacks"):
		get_tree().set_input_as_handled()
		if visible:
			hide()
		else:
			show()
	if event.is_action_pressed("left_click"):
		_put_on_top()


func _on_AttackList_visibility_changed():
	if visible == true:
		_request_attack_list();


func _on_WindowTitle_close_clicked():
	hide()


func _put_on_top() -> void:
	var child_count = get_parent().get_child_count()
	get_parent().move_child(self, child_count)


func _on_WindowTitle_drag_ended():
	_is_dragged = false
	GlobalConfig.set_value(GlobalConfig.SEC_WIN_POS, GlobalConfig.PROP_WIN_ATTACKS, rect_position)


func _on_WindowTitle_drag_started(mouse_offset):
	_mouse_offset = mouse_offset
	_is_dragged = true
