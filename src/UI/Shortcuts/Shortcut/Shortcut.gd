extends PanelContainer


signal shortcut_clicked(shortcut, action_name)

export(bool) var enabled = true
export(String) var shortcut_action_name = "shortcut_1"

onready var _color_player = $ColorPlayer
onready var _label = $Container/Label
onready var _icon = $Container/Icon
onready var _counter_label = $Container/Icon/ItemCount

var shortcut_data: ShortcutData

func _ready():
	var actions = InputMap.get_action_list(shortcut_action_name)
	if actions == null || actions.size() == 0:
		printerr("No action found for shortcut name: " + shortcut_action_name)
		return
	var firstAction = actions[0]
	_label.text = firstAction.as_text()
	GlobalData.shortcut_service.connect("shortcuts_changed", self, "_load_shortcut_data")
	GlobalEvents.connect("onInventoryItemsUpdated", self, "_inventory_items_updated")
	_load_shortcut_data()


"""
If we have a shortcut saved as an item type we want to display its count.
"""
func _inventory_items_updated(updated_items) -> void:
	if shortcut_data == null:
		return
	if shortcut_data.type != ShortcutData.ShortcutType.ITEM:
		return
	var player_item_id = shortcut_data.payload["player_item_id"]
	var updated_item: ItemData = null
	for i in updated_items:
		if i.player_item_id == player_item_id:
			updated_item = i
			break
	if updated_item == null:
		print_debug("shortcut item was not found in updated items")
		return
	_counter_label.text = str(updated_item.amount)


func _load_shortcut_data() -> void:
	shortcut_data = GlobalData.shortcut_service.get_shortcut(shortcut_action_name)
	if shortcut_data:
		_icon.texture = shortcut_data.icon
		if shortcut_data.type == ShortcutData.ShortcutType.ITEM:
			_counter_label.visible = true
	else:
		_icon.texture = null


func _trigger_shortcut_flashing() -> void:
	if not enabled:
		return
	if shortcut_data != null:
		_color_player.stop(true)
		_color_player.play("flash")


func can_drop_data(position, data):
	return (data is ItemData) or (data is AttackData)


func drop_data(position, data):
	if data is ItemData:
		var shortcut = ShortcutData.new()
		shortcut.type = ShortcutData.ShortcutType.ITEM
		shortcut.icon = data.image
		GlobalData.shortcut_service.save_shortcut(shortcut_action_name, shortcut)
		GlobalEvents.emit_signal("onInventoryItemUpdateRequested")
	elif data is AttackData:
		print_debug("attack dropped")


func _unhandled_key_input(event) -> void:
	if event.is_action_pressed(shortcut_action_name):
		emit_signal("shortcut_clicked", shortcut_action_name, self)
		_trigger_shortcut_flashing()


func _on_Shortcut_gui_input(event) -> void:
	if not event is InputEventMouseButton:
		return
	if event.is_action_pressed("left_click"):
		emit_signal("shortcut_clicked", shortcut_action_name, self)
		_trigger_shortcut_flashing()
	if event.is_action_pressed("right_click"):
		GlobalData.shortcut_service.delete_shortcut(shortcut_action_name)
