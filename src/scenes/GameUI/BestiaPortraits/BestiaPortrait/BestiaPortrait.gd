extends MarginContainer

signal portrait_pressed

onready var _portrait = $PanelContainer/Wrapper/Portrait
onready var _bestia_name = $PanelContainer/Wrapper/Content/NameMargin/BestiaName
onready var _hp = $PanelContainer/Wrapper/Content/BarHp
onready var _mana = $PanelContainer/Wrapper/Content/BarMana

var _data: BestiaPortraitData

func set_portrait_data(data: BestiaPortraitData) -> void:
	_bestia_name.text = data.name
	_hp.set_value(data.hp_percentage)
	_mana.set_value(data.mana_percentage)
	_data = data


func _on_PanelContainer_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("left_click"):
			print_debug("Portrait pressed: ", _bestia_name.text)
			emit_signal("portrait_pressed", _data)
