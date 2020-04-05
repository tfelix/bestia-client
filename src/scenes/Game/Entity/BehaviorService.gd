class_name BehaviorService

func get_behavior_for(entity: Entity) -> String:
	var node_name = entity.get_parent().name
	
	var default_behavior = get_default_behavior_for(entity)
	var behavior_group_name = "entity-%s" % [node_name]
	
	return GlobalConfig.get_value("behavior", behavior_group_name, default_behavior)


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
