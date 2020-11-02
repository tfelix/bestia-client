extends Node

# Saves the default interactions with a certain kind of entity
# It avoids to show the user the popup menu all the time as
# soon as a default interaction was set.
var default_interactions = {}

var shortcut_service := ShortcutsService.new()

# Set to the local account which is logged in
# TODO Remove this
var client_account_id: int = 1


