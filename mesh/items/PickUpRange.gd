extends Node
class_name PickUp

signal item_picked(item)

var Actions = load("res://Actions.gd")
var ItemModel = load("res://scenes/game/ui/inventory/ItemModel.gd")
var ItemPickupMessage = load('res://scenes/game/ui/item_pickup_message/ItemPickupMessage.tscn')

# TODO Receive the Mesh of the item and build range collision object based on its BBox.
# TODO Auto Connect the PickUpRange to the Mesh

onready var player = get_tree().get_root().get_node("Game/Player")

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
	var current_pickup_message = root.get_node("Game/ItemPickupMessage")
	if current_pickup_message != null:
		current_pickup_message.queue_free()
	var pickup_message = ItemPickupMessage.instance()
	var item_model = ItemModel.new()
	# item_model.icon = "bottle_icon"
	# item_model.name = "Bottle"
	# item_model.weight = 1
	# item_model.amount = 1
	# pickup_message.init(item_mode)
	
	root.add_child(pickup_message)
	pickup_message.show_message(item_model)

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if !event.is_action(Actions.ACTION_LEFT_CLICK):
		return
	get_tree().set_input_as_handled()
	# var is_player_in_range = $StaticBody.overlaps_body(player)
	# if is_player_in_range:
	_requestPickUp()
