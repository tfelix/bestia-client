extends Control

"""
Emitted if the player wants to equip a certain item into this slot.
"""
signal item_equipped(slot, item_data)

enum CornerRounding { LEFT, RIGHT }

export var slot_name: String
export var enabled: bool = true
export(CornerRounding) var corner_rounding = CornerRounding.LEFT
export(ItemData.EquipSlot) var compatible_equip_slot = ItemData.EquipSlot.NONE

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
	return data is ItemData && data.type == ItemData.ItemType.EQUIP && data.equip_slot == compatible_equip_slot


func drop_data(position, data):
	emit_signal("item_equipped", compatible_equip_slot, data)

