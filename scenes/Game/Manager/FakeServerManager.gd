extends Node

# The fake server listens to messages from the game and instead of sending it
# to the server and reacting on the response it will directly manipulate the game
# with predefined actions.

var PST = load("res://PubSubTopics.gd")
var NoMovementComponent = load("res://scenes/Game/Entity/Component/NoMovement.gd")

func _ready():
	PubSub.subscribe(PST.SERVER_SEND, self)

func free():
  PubSub.unsubscribe(self)
  .free()

func event_published(event_key, payload):
	match (event_key):
		PST.SERVER_SEND:
		# TODO We must detect the different payloads, for now we can only chop
		# tree via this message system as poc
			_chop_tree(payload)


func _chop_tree(entity: Entity):
	var no_movement = NoMovementComponent.new()
	# Some components have a visual clue, others dont
	Global.player.push_back(no_movement)
	# Add Progress Component to player entity
	# After progress is finished despawn tree
	# Remove NoMovement Component
	# Spawn Loot on the Ground
	pass