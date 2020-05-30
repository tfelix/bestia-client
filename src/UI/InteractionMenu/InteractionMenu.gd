extends Control

"""
Emitted if the user has requested an interaction.
"""
signal interaction_requested(interaction)

onready var _follower: SpatialFollower = $SpatialFollower
onready var _use = $Interactions/Use
onready var _inspect = $Interactions/Inspect
onready var _attack = $Interactions/Attack


func _ready():
	_follower.follow_node = get_parent().get_path()


func display_interactions(interactions: Array) -> void:
	_use.hide()
	_inspect.hide()
	_attack.hide()
	if interactions.find("use") != -1:
		_use.show()
	if interactions.find("inspect") != -1:
		_inspect.show()
	if interactions.find("attack") != -1:
		_attack.show()

