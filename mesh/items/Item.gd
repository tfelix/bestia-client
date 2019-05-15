extends Spatial
class_name Item

export(Texture) var item_icon
export(String) var item_name = "undefined"
export(int) var item_weight = 10 # 1 unit is 100gr thus 10 is 1kg

func _on_StaticBody_mouse_entered():
	print_debug("Mouse entered")
	pass # Replace with function body.

func _on_StaticBody_mouse_exited():
	print_debug("Mouse exit")
	pass # Replace with function body.

func _on_PickUp_item_clicked():
	if $Selection.is_selected:
		$Selection.unselected()
	else:
		$Selection.selected()
