extends PopupDialog

onready var _item_img = $MarginContainer/VBox/HBoxHeader/ItemImg
onready var _item_name = $MarginContainer/VBox/HBoxHeader/ItemName
onready var _item_spinner = $MarginContainer/VBox/InputMargin/CenterContainer/HBoxInput/SpinBox

var _item: ItemData

func ask_drop_amount(item: ItemData) -> void:
	_item = item
	_item_spinner.max_value = _item.amount
	_item_img.texture = item.image
	_item_name.text = tr(item.database_name)


func _on_AllButton_pressed() -> void:
	_item_spinner.value = _item_spinner.max_value


func _on_Ok_pressed() -> void:
	var drop_msg = ItemDropMessage.new()
	drop_msg.amount = _item_spinner.value
	drop_msg.player_item_id = _item.player_item_id
	GlobalEvents.emit_signal("onMessageSend", drop_msg)
	queue_free()


func _on_Cancel_pressed() -> void:
	queue_free()


func _on_ItemDropModal_popup_hide():
	queue_free()