extends Control

signal display_finished

onready var _icon = $Margin/HBox/Icon
onready var _label = $Margin/HBox/Label
onready var _player = $AnimationPlayer


var _current_items = {}

var _display_items = []

func _ready():
	GlobalEvents.connect("onInventoryItemsUpdated", self, "_on_inventory_update")


"""
Detects the new items and displays them.
"""
func _on_inventory_update(items) -> void:
	# On initial update just fill what we already have.
	if _current_items.empty():
		for item in items:
			_current_items[item.player_item_id] = item
		return
	
	for item in items:
		if not _current_items.has(item.player_item_id):
			_current_items[item.player_item_id] = item
			_display_items.push_back({"amount": item.amount, "image": item.image, "name": item.tr_database_name})
		else:
			var existing = _current_items[item.player_item_id]
			var d = item.amount - existing.amount
			if d > 0:
				_display_items.push({"amount": d, "image": item.image, "name": item.tr_database_name})
				_current_items[item.player_item_id] = item
	
	_show_next()


func _show_next() -> void:
	if _display_items.empty():
		return
	var next = _display_items.pop_front()
	_icon.texture = next.image
	var text = str(next.amount, "x ", next.name)
	_label.text = text
	_player.play("fade")


func _on_AnimationPlayer_animation_finished(anim_name):
	_show_next()
	emit_signal("display_finished")
