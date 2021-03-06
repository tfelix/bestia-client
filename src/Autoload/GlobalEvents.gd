extends Node

# Entity Signals
signal onEntityClicked(entity, click_event)
signal onEntitySelected(entity)
signal onEntityMouseEntered(entity)
signal onEntityMouseExited(entity)
signal onEntityAdded(entity)
signal onEntityRemoved(entity)
signal onDamageReceived(damage_message)
# These are internal signals which are used by the demo to setup
# some stuff without a proper game server
signal entity_spawned(entity)

# Player Signals
signal terrain_clicked(global_pos)
signal player_entity_updated(player_entity, component)
signal onBuildingEntered(building_id)
signal onBuildingExit(building_id)
signal onCastSelectionStarted(attack)
signal onCastSelectionEnded()
signal onSkillCasted(attack, entity, target)
signal onPlayerUsed(player)
signal onPlayerAttacked(target)
signal onPlayerItemPicked(item_entity)

# Inventory Signals
signal onItemUsed(player_item_id)
"""
Called from the server, when an inventory update message is received.
Its probably better to use direct calls instead of events when
server messages arrive.
"""
signal onInventoryUpdate(inventory_update)
signal onInventoryItemsUpdated(updated_items)
"""
When this signal is send out the inventory is requested to send out
an onInventoryItemsUpdated signal. Usually then some parts of the application
need an updated list of items.
"""
signal onInventoryItemUpdateRequested()

# Equipment Signals
"""
Signal is send when the equipment of a certain slot has changed. If item_data is
null then no equipment is set for this slot.
"""
signal onEquipmentUpdated(slot, item_data)

# Chat Signals
signal onChatReceived(chat)

# Structure Signals
signal onStructurePreConstructionStarted(entity)
signal onStructurePreConstructionEnded(entity)
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
signal onShortcutPressed(shortcut_data)
signal onDebugMode(enabled)

# Environment
signal onTemperatureChanged(temperature)
signal onWeatherChanged(weather)
signal onDaytimeChanged(daytime)
