extends Control

onready var _status_values = $StatusValues
onready var _inventory = $Inventory
onready var _attack_list = $AttackList

func _on_CharacterPlate_on_attacks_pressed():
	_inventory.close()
	_attack_list.open()
	_status_values.hide()


func _on_CharacterPlate_on_inventory_pressed():
	_inventory.open()
	_attack_list.close()
	_status_values.hide()


func _on_CharacterPlate_status_values_pressed():
	_inventory.close()
	_attack_list.close()
	_status_values.show()
