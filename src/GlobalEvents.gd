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
signal onPlayerEntityUpdated(player)
signal onCastStarted(attack_id)
signal onCastEnded()

# Inventory Signals
signal onItemUsed(player_item_id)
signal onInventoryUpdate(inventory_update)

# Chat Signals
signal onChatReceived(chat)

# Structure Signals
signal onStructureConstructionStarted(entity)
signal onStructureConstructionEnded(entity)

# Terrain Signals
signal onTerrainClicked(position)

# Message Signals
signal onMessageSend(message)
signal onMessageReceived(message)

# UI Signals
signal onUiEntered()
signal onUiExited()

# Environment
signal onTemperatureChanged(temperature)
signal onWeatherChanged(weather)
signal onDaytimeChanged(daytime)
