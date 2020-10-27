extends Node

# Saves the default interactions with a certain kind of entity
# It avoids to show the user the popup menu all the time as
# soon as a default interaction was set.
var default_interactions = {}

var shortcut_service := ShortcutsService.new()

# Set to the local account which is logged in
var client_account_id: int = 1

# this is of type Entities, but because of https://github.com/godotengine/godot/issues/27136 
# can not be typed
var entities 


