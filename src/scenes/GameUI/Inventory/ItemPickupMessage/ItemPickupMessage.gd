extends Control

const ItemModel = preload("res://scenes/GameUI/Inventory/ItemModel.gd")

signal display_finished

onready var _icon = $Margin/HBox/Icon
onready var _label = $Margin/HBox/Label
onready var _player = $AnimationPlayer

func show_message(item: ItemModel) -> void:
	_player.stop(true)
	var text = str(item.amount, "x ", item.name)
	_icon.texture = item.icon
	_label.text = text
	_player.play("fade")

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("display_finished")
