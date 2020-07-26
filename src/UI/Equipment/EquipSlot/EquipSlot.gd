extends Control

"""
Emitted if the player wants to equip a certain item into this slot.
"""
signal item_equipped

enum CornerRounding { LEFT, RIGHT }

export var slot_name: String
export var enabled: bool = true
export(CornerRounding) var corner_rounding = CornerRounding.LEFT

onready var _slot_label = $SlotLabel
onready var _panel_right = $PanelRight
onready var _panel_left = $PanelLeft


func _ready():
	_slot_label.text = slot_name
	if corner_rounding == CornerRounding.LEFT:
		_panel_right.hide()
	else:
		_panel_left.hide()


func can_drop_data(position, data) -> bool:
	return data is ItemData


func drop_data(position, data):
	print_debug("Item dropped in slot")
