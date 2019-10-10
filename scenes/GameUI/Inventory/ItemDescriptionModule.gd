extends MarginContainer

var item: ItemModel

onready var _item_name = $DescriptionContainer/TitleContainer/ItemTitle
onready var _item_desc = $DescriptionContainer/ItemDescription
onready var _amount = $DescriptionContainer/Amount
onready var _weight = $DescriptionContainer/Weight
onready var _item_img = $DescriptionContainer/TitleContainer/ItemImg

func show_item_description(new_item: ItemModel) -> void:
	if new_item == null:
		return
	item = new_item
	_item_name.text = tr(item.database_name.to_upper())
	_item_desc.text = tr((item.database_name + "_description").to_upper())
	_item_img.texture = item.image
	_amount.text = "Amount: %s" % item.amount
	_weight.text = "Weight: %skg (%skg ea)" % [item.totalWeight() / 10.0, item.weight / 10.0]
