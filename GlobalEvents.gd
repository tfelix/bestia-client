extends Node

# Entity Signals
signal onEntityClicked(entity, click_event)
signal onEntitySelected(entity)
signal onEntityMouseEntered(entity)
signal onEntityMouseExited(entity)
signal onEntityAdded(entity)
signal onEntityRemoved(entity)

# Player Signals
signal onPlayerInteract(entity, interaction)

# Structure Signals
signal onStructureConstructionStarted(entity)
signal onStructureConstructionEnded(entity)

# Terrain Signals
signal onTerrainClicked(position)

# Server Signals
signal onSendToServer(message)
signal onReceiveFromServer(message)

