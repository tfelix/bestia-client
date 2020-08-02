extends PanelContainer

signal item_unequipped(item_data)

var _equiped_item: ItemData

onready var item_image = $ItemSlot/ImageMargin/ItemImage
onready var item_label = $ItemSlot/ItemName


func equip_item(item_data: ItemData):
	item_label.text = item_data.tr_database_name
	item_image.texture = item_data.image


func _on_EquipContainer_gui_input(event: InputEvent):
	if event.is_action_pressed("right_click"):
		emit_signal("item_unequipped", _equiped_item)
