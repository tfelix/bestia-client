extends Area
class_name PickUp

signal item_picked(item)
signal item_clicked()

var Actions = load("res://Actions.gd")
var ItemModel = load("res://scenes/ui/inventory/ItemModel.gd")
var ItemPickupMessage = load("res://scenes/ui/item_pickup_message/ItemPickupMessage.tscn")

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
	
	# Hide current pickup message if there is any
	var current_pickup_message = root.get_node("Game/ItemPickupMessage")
	if current_pickup_message != null:
		current_pickup_message.queue_free()
	
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

func _on_StaticBody_input_event(camera, event, click_position, click_normal, shape_idx):
	if !event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		return
		
	emit_signal("item_clicked")
	
	var is_player_in_range = overlaps_body(player)
	if is_player_in_range:
		# We have a problem if the look for unhandled_input in the terrain it triggers too soon
		# if we listen to staticInput events instead the click on this static body will.
		# I probably need to write my own raycaster which will handles and controls input in a
		# central way
		get_tree().set_input_as_handled()
		_requestPickUp()
