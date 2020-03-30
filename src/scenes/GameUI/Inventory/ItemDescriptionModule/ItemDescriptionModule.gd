extends MarginContainer
class_name ItemDescriptionModule

var item: InventoryItem

const ItemDropModal = preload("res://scenes/GameUI/Inventory/ItemDropDialog/ItemDropDialog.tscn")

onready var _item_name = $DescriptionContainer/TitleContainer/ItemTitle
onready var _item_desc = $DescriptionContainer/ItemDescription
onready var _amount = $DescriptionContainer/Amount
onready var _weight = $DescriptionContainer/Weight
onready var _item_img = $DescriptionContainer/TitleContainer/ItemImg
onready var _use_btn = $DescriptionContainer/Use


func free():
	GlobalEvents.emit_signal("onPrepareSetShortcut", null)
	.free()


func show_item_description(new_item: InventoryItem) -> void:
	if new_item == null:
		return
	item = new_item
	_item_name.text = tr(item.database_name.to_upper())
	_item_desc.text = tr((item.database_name + "_description").to_upper())
	_item_img.texture = item.image
	_amount.text = "Amount: %s" % item.amount
	_weight.text = "Weight: %skg (%skg ea)" % [item.totalWeight() / 10.0, item.weight / 10.0]
	_use_btn.disabled = !new_item.is_usable()
	
	var shortcut_data = ShortcutData.new()
	shortcut_data.type = "item"
	shortcut_data.icon = item.image.resource_path
	shortcut_data.payload["player_item_id"] = item.player_item_id
	GlobalEvents.emit_signal("onPrepareSetShortcut", shortcut_data)


func _on_Drop_pressed():
	var item_drop_modal = ItemDropModal.instance()
	get_tree().root.add_child(item_drop_modal)
	item_drop_modal.ask_drop_amount(item)
	item_drop_modal.popup_centered()


func _on_Use_pressed():
	var msg = ItemUseRequestMessage.new()
	msg.player_item_id = item.player_item_id
	msg.request_id = UUID.create()
	GlobalEvents.emit_signal("onMessageSend", msg)
