extends MarginContainer
class_name ItemDescriptionModule

const ItemDropDialog = preload("res://UI/Inventory/ItemDropDialog/ItemDropDialog.tscn")

var item: InventoryItem


onready var _item_name = $DescriptionContainer/TitleContainer/ItemTitle
onready var _item_desc = $DescriptionContainer/ItemDescription
onready var _amount = $DescriptionContainer/Amount
onready var _weight = $DescriptionContainer/Weight
onready var _item_img = $DescriptionContainer/TitleContainer/ItemImg
onready var _use_btn = $DescriptionContainer/ButtonBox/Use


func show_item_description(new_item: InventoryItem) -> void:
	if new_item == null:
		return
	item = new_item
	var item_db_name_upper = item.data.database_name.to_upper()
	_item_name.text = tr(item_db_name_upper)
	_item_desc.text = tr(item_db_name_upper + "_DESCRIPTION")
	_item_img.texture = item.data.image
	_amount.text = "Amount: %s" % item.data.amount
	_weight.text = "Weight: %skg (%skg ea)" % [item.totalWeight() / 10.0, item.data.weight / 10.0]
	_use_btn.disabled = !new_item.is_usable()


func _on_Drop_pressed():
	var item_drop_modal = ItemDropDialog.instance()
	get_tree().root.add_child(item_drop_modal)
	item_drop_modal.ask_drop_amount(item)
	item_drop_modal.popup_centered()


func _on_Use_pressed():
	GlobalEvents.emit_signal("onItemUsed", item.data.player_item_id)
