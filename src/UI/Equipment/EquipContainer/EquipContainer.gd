extends PanelContainer

signal item_unequipped

var item: ItemData


func _on_EquipContainer_gui_input(event: InputEvent):
	if event.is_action_pressed("right_click"):
		emit_signal("item_unequipped", item)
