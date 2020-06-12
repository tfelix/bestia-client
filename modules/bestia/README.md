# Bestia Godot-Custom-Module

This is a Godot Game-Engine Custom Module which manages the entity and component transmission and handling from the server into the game client.

## Usage

This module serves mainly two purposes:

1. Deserialization of ProtoBuf messages from the Bestia Game server.
2. Redirecting this data to the EntityNode which can be added to Godot nodes in order to react on changed properties of the data.


## Installation

In order to use it, checkout the Godot Game engine and copy the module into the module folder. Then compile the engine for your platform.

For more detailled instructions see the main README of the client.
