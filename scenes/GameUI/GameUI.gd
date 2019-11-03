extends Control


func _on_MenuButtons_on_inventory_pressed():
	$Inventory.open()


func _on_MenuButtons_on_attacks_pressed():
	$AttackList.open()
