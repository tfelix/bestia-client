extends Node

# Saves the default interactions with a certain kind of entity
# It avoids to show the user the popup menu all the time as
# soon as a default interaction was set.
var default_interactions = {}

var pickup_item_message

var player_camera: Camera