"""
Usually used in order to detect item drops on the background of the game
so the inventory can ask for the item to be dropped to the ground.
"""
extends Control

signal item_dropped(item)

func can_drop_data(position, data):
	return true


func drop_data(position, data):
	print_debug("item dropped")
