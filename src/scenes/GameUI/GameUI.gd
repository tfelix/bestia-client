extends Control


func _on_CharacterPlate_on_attacks_pressed():
	$Inventory.close()
	$AttackList.open()


func _on_CharacterPlate_on_inventory_pressed():
	$Inventory.open()
	$AttackList.close()
