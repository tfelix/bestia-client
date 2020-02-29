extends Control


func _on_MenuButtons_on_inventory_pressed():
	$Inventory.open()
	$AttackList.close()


func _on_MenuButtons_on_attacks_pressed():
	$Inventory.close()
	$AttackList.open()
