extends Node

signal player_changed

# Saves the default interactions with a certain kind of entity
# It avoids to show the user the popup menu all the time as
# soon as a default interaction was set.
var default_interactions = {}

var player_camera: Camera
var player: Node setget player_set

func player_set(value):
	player = value
	emit_signal("player_changed", player)