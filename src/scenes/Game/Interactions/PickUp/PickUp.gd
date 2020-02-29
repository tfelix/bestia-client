extends Node

var Actions = load("res://Actions.gd")
var ItemModel = load("res://scenes/ui/inventory/ItemModel.gd")
var ItemPickupMessage = load("res://scenes/ui/item_pickup_message/ItemPickupMessage.tscn")

onready var item = get_node("../..")

func trigger_interaction(node: Spatial) -> void:
	# TODO We must find a better way to do this check here.
	# var is_player_in_range = $PickUpArea.overlaps_body(player)
	var is_player_in_range = false
	if is_player_in_range:
		_requestPickUp()
	else:
		# TODO Make the player move
		# No: Move player to item, as soon as he is in range, pick up
		# Send callback end of movement to player?
		# Wire to Player signal? End of movement? <-- Better
		print_debug("Move Player to item and pick up")

func _requestPickUp():
	# Send Signal to Server with request for pickup
	# If server confirms we pick up item.
	_pickup()
	pass

func _pickup():
  # Send Signal to player inventory if it exists with item
  get_parent().queue_free()
  _displayPickupMessage()
  pass

func _displayPickupMessage():
	var root = get_tree().get_root()
	
	var existing_pickup_message = root.find_node("ItemPickupMessage", false)
	if existing_pickup_message != null:
		existing_pickup_message.queue_free()

	var item_model = ItemModel.new()
	var item = get_parent()
	
	item_model.icon = item.item_icon
	item_model.name = item.item_name
	item_model.weight = item.item_weight
	# Amount must be given by the server
	item_model.amount = 1
	
	var pickup_message = ItemPickupMessage.instance()
	root.add_child(pickup_message)
	pickup_message.show_message(item_model)
	
	root.add_child(pickup_message)
	pickup_message.show_message(item_model)
  
