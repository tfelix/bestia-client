extends Node
class_name GlobalData

signal player_changed

# Saves the default interactions with a certain kind of entity
# It avoids to show the user the popup menu all the time as
# soon as a default interaction was set.
var default_interactions = {}

# Set to the local account which is logged in
var client_account: int = 1

var player_camera: Camera
var entities # this is of type Entities, but because of https://github.com/godotengine/godot/issues/27136 can not be typed
var player_data: PlayerData = PlayerData.new()