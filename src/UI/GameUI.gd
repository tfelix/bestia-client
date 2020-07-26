extends Control

onready var _status_values = $StatusValues
onready var _inventory = $Inventory
onready var _attack_list = $AttackList
onready var _item_dropzone = $ItemDropZone
onready var _equipment = $Equipment
onready var _menu = $GameMenu

func _on_CharacterPlate_on_attacks_pressed():
	if _attack_list.visible:
		_attack_list.hide()
	else:
		_attack_list.show()


func _on_CharacterPlate_on_inventory_pressed():
	if _inventory.visible:
		_inventory.hide()
	else:
		_inventory.show()


func _on_CharacterPlate_status_values_pressed():
	if _status_values.visible:
		_status_values.hide()
	else:
		_status_values.show()


func _on_CharacterPlate_equip_pressed():
	if _equipment.visible:
		_equipment.hide()
	else:
		_equipment.show()


func _on_ItemDropZone_item_dropped(item_data, dropzone):
	_inventory.drop_item(item_data)


func _unhandled_key_input(event: InputEventKey):
	if event.is_action("ui_cancel"):
		if not _menu.visible:
			_menu.show()
		else:
			_menu.hide()
		# This is probably a bad idea as we want the cancel for other stuff ingame as well
		get_tree().set_input_as_handled()
