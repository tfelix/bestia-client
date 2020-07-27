class_name InteractionService

signal response_received(interactions)

const InteractionMenu = preload("res://UI/InteractionMenu/InteractionMenu.tscn")

var _interaction_menu
var _requested_entity

func _init():
	_interaction_menu = InteractionMenu.instance()
	_interaction_menu.visible = false
	GlobalEvents.connect("onMessageReceived", self, "_receive_response")


func _receive_response(msg: InteractionResponse) -> void:
	if msg == null:
		return
	if _requested_entity == null or msg.entity_id != _requested_entity.id:
		return
	_requested_entity.get_spatial().add_child(_interaction_menu)
	_interaction_menu.visible = true
	_interaction_menu.display_interactions(msg.interactions)


"""
Displays the menu with all possible interactions
"""
func show_behavior_selection(entity: Entity) -> void:
	_requested_entity = entity
	var request = InteractionRequest.new()
	request.entity_id = entity.id
	GlobalEvents.emit_signal("onMessageSend", request)


func hide_behavior_selection() -> void:
	_interaction_menu.visible = false


"""
To fetch the behavior for the entity we see if there is user saved behavior,
we check if this behavior is still possible for this entity and return it if
this is the case.
If the behavior is not possibly (or not saved) we return the default interaction.
"""
func get_behavior_for(entity: Entity) -> String:
	_request_possible_interactions(entity)
	
	var default_interaction = get_default_behavior_for(entity)
	
	var node_name = entity.get_parent().name
	var behavior_group_name = "entity-%s" % [node_name]
	var saved_interaction = GlobalConfig.get_value("interaction", behavior_group_name, default_interaction)

	
	#if server_interactions.find(saved_interaction) != -1:
	#	return saved_interaction
	
	return default_interaction


func _request_possible_interactions(entity: Entity):
	# Create a request to the server and if the server returns then update the opened
	# menue.
	return ["use"]


func get_default_behavior_for(entity: Entity) -> String:
	var group = entity.behavior_group
	# primary entity -> type
	# bäumen -> type/hacken -> BehaviorGroup
	# gegner -> type
	match group:
		Entity.BehaviorGroup.ATTACK:
			return "attack"
		Entity.BehaviorGroup.INTERACT:
			return "interact"
		Entity.BehaviorGroup.NOTHING:
			return "nothing"
		Entity.BehaviorGroup.PICKUP:
			return "pickup"
		Entity.BehaviorGroup.TALK:
			return "talk"
		Entity.BehaviorGroup.USE:
			return "use"
		_:
			return "unknown"


func _behavior_to_string(behavior) -> String:
	match typeof(behavior):
		Entity.BehaviorGroup.ATTACK:
			return "attack"
		Entity.BehaviorGroup.INTERACT:
			return "interact"
		Entity.BehaviorGroup.NOTHING:
			return "nothing"
		Entity.BehaviorGroup.PICKUP:
			return "pickup"
		Entity.BehaviorGroup.TALK:
			return "talk"
		_:
			return "unknown"
