extends Control

onready var _status_values = $StatusValues
onready var _inventory = $Inventory
onready var _attack_list = $AttackList
onready var _item_dropzone = $ItemDropZone
onready var _equipment = $Equipment

func _on_CharacterPlate_on_attacks_pressed():
	_item_dropzone.visible = false
	_inventory.hide()
	_status_values.hide()
	_equipment.hide()
	if _attack_list.visible:
		_attack_list.hide()
	else:
		_attack_list.show()


func _on_CharacterPlate_on_inventory_pressed():
	_item_dropzone.visible = true
	_attack_list.hide()
	_status_values.hide()
	_equipment.hide()
	if _inventory.visible:
		_inventory.hide()
	else:
		_inventory.show()


func _on_CharacterPlate_status_values_pressed():
	_item_dropzone.visible = false
	_inventory.hide()
	_attack_list.hide()
	_equipment.hide()
	if _status_values.visible:
		_status_values.hide()
	else:
		_status_values.show()


func _on_CharacterPlate_equip_pressed():
	_item_dropzone.visible = false
	_inventory.hide()
	_attack_list.hide()
	_status_values.hide()
	if _equipment.visible:
		_equipment.hide()
	else:
		_equipment.show()


func _on_ItemDropZone_item_dropped(item_data, dropzone):
	_inventory.drop_item(item_data)
