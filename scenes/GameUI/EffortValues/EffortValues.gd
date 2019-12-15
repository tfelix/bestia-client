extends Control

var _effort_values = EffortValues.new()
var _delta_effort_values = EffortValues.new()

onready var _str = $Rows/StatColoumns/ValueColumn/StrValue
onready var _vit = $Rows/StatColoumns/ValueColumn/VitValue
onready var _int = $Rows/StatColoumns/ValueColumn/IntValue
onready var _wis = $Rows/StatColoumns/ValueColumn/WisValue
onready var _dex = $Rows/StatColoumns/ValueColumn/DexValue
onready var _agi = $Rows/StatColoumns/ValueColumn/AgiValue

onready var _str_needed = $Rows/StatColoumns/NeededColumn/StrNeeded
onready var _vit_needed = $Rows/StatColoumns/NeededColumn/VitNeeded
onready var _int_needed = $Rows/StatColoumns/NeededColumn/IntNeeded
onready var _wis_needed = $Rows/StatColoumns/NeededColumn/WisNeeded
onready var _dex_needed = $Rows/StatColoumns/NeededColumn/DexNeeded
onready var _agi_needed = $Rows/StatColoumns/NeededColumn/AgiNeeded

onready var _str_btn = $Rows/StatColoumns/ButtonColumn/StrUp
onready var _vit_btn = $Rows/StatColoumns/ButtonColumn/VitUp
onready var _int_btn = $Rows/StatColoumns/ButtonColumn/IntUp
onready var _wis_btn = $Rows/StatColoumns/ButtonColumn/WisUp
onready var _dex_btn = $Rows/StatColoumns/ButtonColumn/DexUp
onready var _agi_btn = $Rows/StatColoumns/ButtonColumn/AgiUp

onready var _available = $Rows/AvailableGain

var _original_gain = 13
var _available_gain = 13

# Called when the node enters the scene tree for the first time.
func _ready():
	_draw_available_points()
	_calculate_needed_points()
	_check_up_btn_enable()
	_draw_effort_values()


func _draw_available_points() -> void:
	_available.text = str(_available_gain)


func _check_up_btn_enable() -> void:
	if _available_gain < _get_gain_needed(_effort_values.eff_str_value + _delta_effort_values.eff_str_value + 1):
		_str_btn.disabled = true
	else:
		_str_btn.disabled = false
	if _available_gain < _get_gain_needed(_effort_values.eff_vit_value + _delta_effort_values.eff_vit_value + 1):
		_vit_btn.disabled = true
	else:
		_str_btn.disabled = false
	if _available_gain < _get_gain_needed(_effort_values.eff_int_value + _delta_effort_values.eff_int_value + 1):
		_int_btn.disabled = true
	else:
		_str_btn.disabled = false
	if _available_gain < _get_gain_needed(_effort_values.eff_wis_value + _delta_effort_values.eff_wis_value + 1):
		_wis_btn.disabled = true
	else:
		_wis_btn.disabled = false
	if _available_gain < _get_gain_needed(_effort_values.eff_dex_value + _delta_effort_values.eff_dex_value + 1):
		_dex_btn.disabled = true
	else:
		_dex_btn.disabled = false
	if _available_gain < _get_gain_needed(_effort_values.eff_agi_value + _delta_effort_values.eff_agi_value + 1):
		_agi_btn.disabled = true
	else:
		_agi_btn.disabled = false


func _draw_effort_values() -> void:
	_str.text = str(_effort_values.eff_str_value + _delta_effort_values.eff_str_value)
	_vit.text = str(_effort_values.eff_vit_value + _delta_effort_values.eff_vit_value)
	_int.text = str(_effort_values.eff_int_value + _delta_effort_values.eff_int_value)
	_wis.text = str(_effort_values.eff_wis_value + _delta_effort_values.eff_wis_value)
	_dex.text = str(_effort_values.eff_dex_value + _delta_effort_values.eff_dex_value)
	_agi.text = str(_effort_values.eff_agi_value + _delta_effort_values.eff_agi_value)


func _calculate_needed_points() -> void:
	_str_needed.text = str(_get_gain_needed(_effort_values.eff_str_value + _delta_effort_values.eff_str_value + 1))
	_vit_needed.text = str(_get_gain_needed(_effort_values.eff_vit_value + _delta_effort_values.eff_vit_value + 1))
	_int_needed.text = str(_get_gain_needed(_effort_values.eff_int_value + _delta_effort_values.eff_int_value + 1))
	_wis_needed.text = str(_get_gain_needed(_effort_values.eff_wis_value + _delta_effort_values.eff_wis_value + 1))
	_dex_needed.text = str(_get_gain_needed(_effort_values.eff_dex_value + _delta_effort_values.eff_dex_value + 1))
	_agi_needed.text = str(_get_gain_needed(_effort_values.eff_agi_value + _delta_effort_values.eff_agi_value + 1))


func _get_gain_needed(cur_value: int) -> int:
	return int(max(1, floor(0.25 * (cur_value + 1)) * 2))


func _redraw_texts() -> void:
	_draw_available_points()
	_calculate_needed_points()
	_check_up_btn_enable()
	_draw_effort_values()

func _on_StrUp_pressed():
	var needed = _get_gain_needed(_effort_values.eff_str_value + _delta_effort_values.eff_str_value + 1)
	_available_gain -= needed
	_delta_effort_values.eff_str_value += 1
	_redraw_texts()


func _on_CancelBtn_pressed():
	_available_gain = _original_gain
	_delta_effort_values.eff_str_value = 0
	_delta_effort_values.eff_vit_value = 0
	_delta_effort_values.eff_int_value = 0
	_delta_effort_values.eff_wis_value = 0
	_delta_effort_values.eff_dex_value = 0
	_delta_effort_values.eff_agi_value = 0
	_redraw_texts()


func _on_VitUp_pressed():
	var needed = _get_gain_needed(_effort_values.eff_vit_value + _delta_effort_values.eff_vit_value + 1)
	_available_gain -= needed
	_delta_effort_values.eff_vit_value += 1
	_redraw_texts()


func _on_IntUp_pressed():
	var needed = _get_gain_needed(_effort_values.eff_int_value + _delta_effort_values.eff_int_value + 1)
	_available_gain -= needed
	_delta_effort_values.eff_int_value += 1
	_redraw_texts()


func _on_WisUp_pressed():
	var needed = _get_gain_needed(_effort_values.eff_wis_value + _delta_effort_values.eff_wis_value + 1)
	_available_gain -= needed
	_delta_effort_values.eff_wis_value += 1
	_redraw_texts()


func _on_DexUp_pressed():
	var needed = _get_gain_needed(_effort_values.eff_dex_value + _delta_effort_values.eff_dex_value + 1)
	_available_gain -= needed
	_delta_effort_values.eff_dex_value += 1
	_redraw_texts()


func _on_AgiUp_pressed():
	var needed = _get_gain_needed(_effort_values.eff_agi_value + _delta_effort_values.eff_agi_value + 1)
	_available_gain -= needed
	_delta_effort_values.eff_agi_value += 1
	_redraw_texts()
