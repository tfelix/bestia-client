extends PanelContainer

onready var _save_btn = $MainContainer/Body/MarginContainer/StatusValues/GainPointsContainer/GainPoints/Save

onready var _gain_points = $MainContainer/Body/MarginContainer/StatusValues/GainPointsContainer
onready var _gain_label = $MainContainer/Body/MarginContainer/StatusValues/GainPointsContainer/GainPoints/MarginContainer/AvailablePoints

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

onready var _mdef = $MainContainer/Body/MarginContainer1/StatusBasedValues1/MagicDefense/Value
onready var _def = $MainContainer/Body/MarginContainer1/StatusBasedValues1/PhysicalDefense/Value
onready var _crit = $MainContainer/Body/MarginContainer1/StatusBasedValues1/Crit/Value
onready var _cast = $MainContainer/Body/MarginContainer1/StatusBasedValues1/CastTime/Value
onready var _duration = $MainContainer/Body/MarginContainer1/StatusBasedValues1/SpellDuration/Value
onready var _aspd = $MainContainer/Body/MarginContainer1/StatusBasedValues1/ASPD/Value
onready var _walkspeed = $MainContainer/Body/MarginContainer1/StatusBasedValues1/Walkspeed/Value
onready var _hp_regen = $MainContainer/Body/MarginContainer2/StatusBasedValues2/HPTick/Value
onready var _mana_regen = $MainContainer/Body/MarginContainer2/StatusBasedValues2/ManaTick/Value
onready var _stamina_regen = $MainContainer/Body/MarginContainer2/StatusBasedValues2/StaminaTick/Value

var _is_pristine = true

var _mouse_offset = Vector2(0, 0)
var _is_dragged = false

var _available_gain_points = 120

var _status_values: StatusValueData = StatusValueData.new()
var _modified_status_values: StatusValueData = StatusValueData.new()
var _effort_values: StatusValueData = StatusValueData.new()
var _status_based_values: StatusBasedValueData = StatusBasedValueData.new()

export(Color) var reduced_status_color = Color(0.796875, 0.174316, 0.174316)
export(Color) var upped_status_color = Color(0.17, 0.8, 0.27)


func _ready():
	GlobalEvents.connect("onPlayerEntityUpdated", self, "_update_values")
	GlobalEvents.connect("onMessageReceived", self, "_update_gainpoints")
	_check_up_buttons_state()
	_update_status_values()
	_request_gainpoints()
	
	# Setup the initial position
	var win_pos = GlobalConfig.get_value(GlobalConfig.SEC_WIN_POS, GlobalConfig.PROP_WIN_STATUS, Vector2(0, 0))
	rect_position = win_pos


func _process(delta):
	if _is_dragged:
		var mouse_pos = get_viewport().get_mouse_position()
		rect_position = mouse_pos - _mouse_offset


func _update_gainpoints(msg) -> void:
	if msg is GainPointData:
		_available_gain_points = msg.value
	elif msg is StatusValueData:
		_status_based_values = msg
	else:
		return
	_check_up_buttons_state()
	_update_status_values()


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
	if _available_gain_points == 0 && _is_pristine:
		_gain_points.visible = false
	else:
		_gain_points.visible = true

	_save_btn.disabled = _is_pristine
	
	var str_cost = _get_up_gain_cost(_effort_values.strength + 1)
	_strength_cost.text = "%d" % str_cost
	_strength_up.disabled = str_cost > _available_gain_points
	
	var vit_cost = _get_up_gain_cost(_effort_values.vitality + 1)
	_vitality_cost.text = "%d" % vit_cost
	_vitality_up.disabled = vit_cost > _available_gain_points
	
	var int_cost = _get_up_gain_cost(_effort_values.intelligence + 1)
	_int_cost.text = "%d" % int_cost
	_int_up.disabled = int_cost > _available_gain_points
	
	var agi_cost = _get_up_gain_cost(_effort_values.agility + 1)
	_agi_cost.text = "%d" % agi_cost
	_agi_up.disabled = agi_cost > _available_gain_points
	
	var dex_cost = _get_up_gain_cost(_effort_values.dexterity + 1)
	_dex_cost.text = "%d" % dex_cost
	_dex_up.disabled = dex_cost > _available_gain_points
	
	var wil_cost = _get_up_gain_cost(_effort_values.willpower + 1)
	_wil_cost.text = "%d" % wil_cost
	_wil_up.disabled = vit_cost > _available_gain_points


func _get_up_gain_cost(next_value: int) -> int:
	return int(max(1, next_value / 3.0))


func _update_status_values() -> void:
	_strength.text = str(_status_values.strength + _effort_values.strength)
	_vitality.text = str(_status_values.vitality + _effort_values.vitality)
	_int.text = str(_status_values.intelligence + _effort_values.intelligence)
	_agi.text = str(_status_values.agility + _effort_values.agility)
	_dex.text = str(_status_values.dexterity + _effort_values.dexterity)
	_wil.text = str(_status_values.willpower + _effort_values.willpower)
	
	_setup_modifier_color(_strength_mod, _status_values.strength, _modified_status_values.strength)
	_setup_modifier_color(_vitality_mod, _status_values.vitality, _modified_status_values.vitality)
	_setup_modifier_color(_int_mod, _status_values.intelligence, _modified_status_values.intelligence)
	_setup_modifier_color(_agi_mod, _status_values.agility, _modified_status_values.agility)
	_setup_modifier_color(_dex_mod, _status_values.dexterity, _modified_status_values.dexterity)
	_setup_modifier_color(_wil_mod, _status_values.willpower, _modified_status_values.willpower)
	
	_def.text = "%.1f%%" % _status_based_values.def
	_mdef.text = "%.1f%%" % _status_based_values.mdef
	_crit.text = "%.1f%%" % _status_based_values.crit
	_cast.text = "%.1f%%" % _status_based_values.cast_time
	_duration.text = "%.1f%%" % _status_based_values.spell_duration
	_aspd.text = "%.1f%%" % _status_based_values.aspd
	_walkspeed.text = "%.1f%%" % _status_based_values.walkspeed
	_hp_regen.text = "%d" % _status_based_values.hp_regen
	_mana_regen.text = "%d" % _status_based_values.mana_regen
	_stamina_regen.text = "%d" % _status_based_values.stamina_regen


func _update_values(player: Entity) -> void:
	var data = player.get_component(StatusComponent.NAME) as StatusComponent
	if data == null:
		return
	_update_status_values()


func _on_Close_pressed() -> void:
	hide()


func _request_gainpoints() -> void:
	var msg = RequestGainPointMessage.new()
	GlobalEvents.emit_signal("onMessageSend", msg)


func _on_StrUp_pressed():
	_is_pristine = false
	_available_gain_points -= _get_up_gain_cost(_effort_values.strength + 1)
	_effort_values.strength += 1
	_check_up_buttons_state()
	_update_status_values()


func _on_VitUp_pressed():
	_is_pristine = false
	_available_gain_points -= _get_up_gain_cost(_effort_values.vitality + 1)
	_effort_values.vitality += 1
	_check_up_buttons_state()
	_update_status_values()


func _on_IntUp_pressed():
	_is_pristine = false
	_available_gain_points -= _get_up_gain_cost(_effort_values.intelligence + 1)
	_effort_values.intelligence += 1
	_check_up_buttons_state()
	_update_status_values()


func _on_AgiUp_pressed():
	_is_pristine = false
	_available_gain_points -= _get_up_gain_cost(_effort_values.agility + 1)
	_effort_values.agility += 1
	_check_up_buttons_state()
	_update_status_values()


func _on_DexUp_pressed():
	_is_pristine = false
	_available_gain_points -= _get_up_gain_cost(_effort_values.dexterity + 1)
	_effort_values.dexterity += 1
	_check_up_buttons_state()
	_update_status_values()


func _on_WilUp_pressed():
	_is_pristine = false
	_available_gain_points -= _get_up_gain_cost(_effort_values.willpower + 1)
	_effort_values.willpower += 1
	_check_up_buttons_state()
	_update_status_values()


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_status_values"):
		get_tree().set_input_as_handled()
		if visible:
			hide()
		else:
			show()
	if event.is_action_pressed("left_click"):
		_put_on_top()


func _on_Save_pressed():
	# TODO Persist to the server
	_is_pristine = true
	_check_up_buttons_state()


func _on_StatusValues_mouse_entered():
	GlobalEvents.emit_signal("onUiEntered")


func _on_StatusValues_mouse_exited():
	GlobalEvents.emit_signal("onUiExited")


func _on_Title_close_clicked():
	hide()


func _put_on_top() -> void:
	var child_count = get_parent().get_child_count()
	get_parent().move_child(self, child_count)


func _on_Title_drag_started(mouse_offset):
	_mouse_offset = mouse_offset
	_is_dragged = true
	_put_on_top()


func _on_Title_drag_ended():
	_is_dragged = false
	GlobalConfig.set_value(GlobalConfig.SEC_WIN_POS, GlobalConfig.PROP_WIN_STATUS, rect_position)
