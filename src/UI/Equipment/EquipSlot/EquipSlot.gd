extends Control


export var slot_name: String

onready var _slot_label = $SlotLabel


func _ready():
	_slot_label.text = slot_name

