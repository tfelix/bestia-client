extends MarginContainer
class_name ItemDescriptionModule

var item: ItemModel

const ItemDropModal = preload("res://scenes/GameUI/Inventory/ItemDropDialog/ItemDropDialog.tscn")

onready var _item_name = $DescriptionContainer/TitleContainer/ItemTitle
onready var _item_desc = $DescriptionContainer/ItemDescription
onready var _amount = $DescriptionContainer/Amount
onready var _weight = $DescriptionContainer/Weight
onready var _item_img = $DescriptionContainer/TitleContainer/ItemImg
onready var _use_btn = $DescriptionContainer/Use
onready var _shortcuts = $DescriptionContainer/CenterShortcuts/Shortcuts

var _current_item_trigger = null

func _ready():
	_shortcuts.connect("shortcut_triggered", self, "_save_item_to_shortcut")


func _on_item_use_response(msg: ItemUseResponseMessage) -> void:
	if !msg.can_use:
		print_debug("Can not use item ", msg.player_item_id, " (", msg.request_id  ,")")
		return
	
	if item.type == ItemModel.ItemType.CONSUMEABLE:
		var itemUseMsg = ItemUseMessage.new()
		itemUseMsg.player_item_id = item.player_item_id
		GlobalEvents.emit_signal("onMessageSend", msg)
		return
	
	var item_name = item.database_name.capitalize().replace(" ", "")
	var item_path = "res://scenes/Game/Entity/Struct/%s/%s.tscn" % [item_name, item_name.to_lower()]
	var item_scene = load(item_path)
	var item_instance = item_scene.instance()
	get_tree().root.add_child(item_instance)
	item_instance.start_construct()


func show_item_description(new_item: ItemModel) -> void:
	if new_item == null:
		return
	item = new_item
	_item_name.text = tr(item.database_name.to_upper())
	_item_desc.text = tr((item.database_name + "_description").to_upper())
	_item_img.texture = item.image
	_amount.text = "Amount: %s" % item.amount
	_weight.text = "Weight: %skg (%skg ea)" % [item.totalWeight() / 10.0, item.weight / 10.0]
	_use_btn.disabled = !new_item.is_usable()
	
	# Prepare the shortcut trigger
	var item_trigger = ItemTrigger.new()
	item_trigger.icon = item.image_path()
	item_trigger.player_item_id = item.player_item_id
	_current_item_trigger = item_trigger


func _save_item_to_shortcut(shortcut) -> void:
	if _current_item_trigger == null:
		return
	shortcut.on_shortcut_clicked = _current_item_trigger


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
