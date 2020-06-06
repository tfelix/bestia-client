extends PanelContainer

onready var _click = $CloseClick

onready var _gain_label = $MainContainer/Body/MarginContainer/StatusValues/GainPoints/MarginContainer/AvailablePoints

onready var _strength = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrValue
onready var _strength_mod = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrMod
onready var _strength_cost = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrCost
onready var _strength_up = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrUp

onready var _vitality = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitValue
onready var _vitality_mod = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitMod
onready var _vitality_cost = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitCost
onready var _vitality_up = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitUp

onready var _int = $MainContainer/Body/MarginContainer/StatusValues/Intelligence/IntValue
onready var _int_mod = $MainContainer/Body/MarginContainer/StatusValues/Intelligence/IntMod
onready var _int_cost = $MainContainer/Body/MarginContainer/StatusValues/Intelligence/IntCost
onready var _int_up = $MainContainer/Body/MarginContainer/StatusValues/Intelligence/IntUp

onready var _agi = $MainContainer/Body/MarginContainer/StatusValues/Agility/AgiValue
onready var _agi_mod = $MainContainer/Body/MarginContainer/StatusValues/Agility/AgiMod
onready var _agi_cost = $MainContainer/Body/MarginContainer/StatusValues/Agility/AgiCost
onready var _agi_up = $MainContainer/Body/MarginContainer/StatusValues/Agility/AgiUp

onready var _dex = $MainContainer/Body/MarginContainer/StatusValues/Dexterity/DexValue
onready var _dex_mod = $MainContainer/Body/MarginContainer/StatusValues/Dexterity/DexMod
onready var _dex_cost = $MainContainer/Body/MarginContainer/StatusValues/Dexterity/DexCost
onready var _dex_up = $MainContainer/Body/MarginContainer/StatusValues/Dexterity/DexUp

onready var _wil = $MainContainer/Body/MarginContainer/StatusValues/Willpower/WilValue
onready var _wil_mod = $MainContainer/Body/MarginContainer/StatusValues/Willpower/WilMod
onready var _wil_cost = $MainContainer/Body/MarginContainer/StatusValues/Willpower/WilCost
onready var _wil_up = $MainContainer/Body/MarginContainer/StatusValues/Willpower/WilUp

onready var _save_btn = $MainContainer/ButtonRow/Save

var _is_pristine = true

var _available_gain_points = 0

var _strength_cost_value = 0
var _vitality_cost_value = 0

var _status_values: StatusValueData = StatusValueData.new()
var _modified_status_values: StatusValueData = StatusValueData.new()
var _effort_values: StatusValueData = StatusValueData.new()

export(Color) var reduced_status_color = Color(0.796875, 0.174316, 0.174316)
export(Color) var upped_status_color = Color(0.17, 0.8, 0.27)


func _ready():
	GlobalEvents.connect("onPlayerEntityUpdated", self, "_update_values")
	GlobalEvents.connect("onMessageReceived", self, "_update_gainpoints")
	_check_up_buttons_state()
	_request_gainpoints()


func _update_gainpoints(msg) -> void:
	if not msg is GainPointData:
		return
	_available_gain_points = msg.value
	_check_up_buttons_state()


"""
Sets the color to red or green, depending if we got values added or removed.
"""
func _setup_modifier_color(mod_label: Label, value: int, mod_value: int) -> void:
	var mod = value - mod_value
	mod_label.visible = true
	if mod > 0:
		mod_label.text = "+%s" % str(mod)
		mod_label.add_color_override("font_color", upped_status_color)
	elif mod < 0:
		mod_label.text = "-%s" % str(mod)
		mod_label.add_color_override("font_color", reduced_status_color)
	else:
		mod_label.text = "+0"


"""
Checks if the up buttons should stay enabled depending on the the available
gain points.
"""
func _check_up_buttons_state() -> void:
	_gain_label.text = "Available Points: %d" % _available_gain_points
	
	var str_cost = _get_up_gain_cost(_effort_values.strength + 1)
	_strength_cost.text = "%d (%d)" % [_effort_values.strength, str_cost]
	_strength_up.disabled = str_cost > _available_gain_points
	
	var vit_cost = _get_up_gain_cost(_effort_values.vitality + 1)
	_vitality_cost.text = "%d (%d)" % [_effort_values.vitality, vit_cost]
	_vitality_up.disabled = vit_cost > _available_gain_points
	
	var int_cost = _get_up_gain_cost(_effort_values.intelligence + 1)
	_int_cost.text = "%d (%d)" % [_effort_values.intelligence, int_cost]
	_int_up.disabled = int_cost > _available_gain_points
	
	var agi_cost = _get_up_gain_cost(_effort_values.agility + 1)
	_agi_cost.text = "%d (%d)" % [_effort_values.agility, agi_cost]
	_agi_up.disabled = agi_cost > _available_gain_points
	
	var dex_cost = _get_up_gain_cost(_effort_values.dexterity + 1)
	_dex_cost.text = "%d (%d)" % [_effort_values.dexterity, dex_cost]
	_dex_up.disabled = dex_cost > _available_gain_points
	
	var wil_cost = _get_up_gain_cost(_effort_values.willpower + 1)
	_wil_cost.text = "%d (%d)" % [_effort_values.willpower, wil_cost]
	_wil_up.disabled = vit_cost > _available_gain_points


func _get_up_gain_cost(next_value: int) -> int:
	return int(max(1, int(next_value / 10.0)))


func _update_values(player: Entity) -> void:
	var data = player.get_component(StatusComponent.NAME) as StatusComponent
	if data == null:
		return
	_setup_modifier_color(_strength_mod, _status_values.strength, _modified_status_values.strength)
	_setup_modifier_color(_vitality_mod, _status_values.vitality, _modified_status_values.vitality)
	_setup_modifier_color(_int, _status_values.intelligence, _modified_status_values.intelligence)


func hide() -> void:
	_click.play()
	.hide()


func show() -> void:
	_click.play()
	.show()


func _on_Close_pressed() -> void:
	hide()


func _request_gainpoints() -> void:
	var msg = RequestGainPointMessage.new()
	GlobalEvents.emit_signal("onMessageSend", msg)


func _on_StrUp_pressed():
	_is_pristine = false
	_save_btn.disabled = false
	_available_gain_points -= _get_up_gain_cost(_effort_values.strength + 1)
	_effort_values.strength += 1
	_check_up_buttons_state()


func _on_VitUp_pressed():
	_is_pristine = false
	_save_btn.disabled = false
	_available_gain_points -= _get_up_gain_cost(_effort_values.vitality + 1)
	_effort_values.vitality += 1
	_check_up_buttons_state()


func _unhandled_key_input(event):
	if not event.is_action_pressed("ui_status_values"):
		return
	
	if visible:
		hide()
	else:
		show()


func _on_Save_pressed():
	pass # Replace with function body.


func _on_Cancel_pressed():
	# reset possible gain values which where not saved
	hide()


func _on_StatusValues_mouse_entered():
	GlobalEvents.emit_signal("onUiEntered")


func _on_StatusValues_mouse_exited():
	GlobalEvents.emit_signal("onUiExited")
