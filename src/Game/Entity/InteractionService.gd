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
	


func get_behavior_for(entity: Entity) -> String:
	var server_interactions = _request_possible_interactions(entity)
	
	# TODO find better way to group entities
	var default_interaction = get_default_behavior_for(entity)
	
	var node_name = entity.get_parent().name
	var behavior_group_name = "entity-%s" % [node_name]
	var saved_interaction = GlobalConfig.get_value("interaction", behavior_group_name)
	
	if server_interactions.find(saved_interaction) != -1:
		return saved_interaction
	
	if server_interactions.find(default_interaction) != -1:
		return default_interaction
	
	return "unknown"


func _request_possible_interactions(entity: Entity):
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
