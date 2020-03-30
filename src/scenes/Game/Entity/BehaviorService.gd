class_name BehaviorService

func get_behavior_for(entity: Entity) -> String:
	# Check available behaviors
	var interactions = entity.get_node("Interactions")
	
	var saved_behavior = get_saved_behavior_for(entity)
	# Get group and check if saved behavior for group
	
	# If not found get default behavior for group
	
	# Is this behavior possible? yes: ok, no: no behavior can be found
	
	return ""


func get_saved_behavior_for(entity: Entity) -> String:
	var default_behavior = get_default_behavior_for(entity)
	var behavior_group_name = _behavior_to_string(entity.behavior_group)
	
	return GlobalConfig.get_value("behavior", behavior_group_name, default_behavior)


func get_default_behavior_for(entity: Entity):
	var group = entity.behavior_group
	# primary entity -> type
	# bäumen -> type/hacken -> BehaviorGroup
	# gegner -> type
	match typeof(entity.behavior_group):
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
