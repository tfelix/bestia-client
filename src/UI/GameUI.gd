extends Control

onready var _status_values = $StatusValues
onready var _inventory = $Inventory
onready var _attack_list = $AttackList

func _on_CharacterPlate_on_attacks_pressed():
	_inventory.hide()
	_attack_list.show()
	_status_values.hide()


func _on_CharacterPlate_on_inventory_pressed():
	_inventory.show()
	_attack_list.hide()
	_status_values.hide()


func _on_CharacterPlate_status_values_pressed():
	_inventory.hide()
	_attack_list.hide()
	if _status_values.visible:
		_status_values.hide()
	else:
		_status_values.show()
