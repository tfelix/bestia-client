"""
Usually used in order to detect item drops on the background of the game
so the inventory can ask for the item to be dropped to the ground.
"""
extends Control

signal item_dropped(item_data, dropzone)

"""
Name of the dropzone where the item is dropped.
"""
export var dropzone: String

func can_drop_data(position, data):
	return data is ItemData

func drop_data(position, data):
	emit_signal("item_dropped", data, dropzone)
