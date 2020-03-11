class BehaviorService:

	func get_behavior_for(entity: Entity) -> String:
		# Check available behaviors
		var interactions = entity.get_node("Interactions")
		
		# Get group and check if saved behavior for group
		
		# If not found get default behavior for group
		
		# Is this behavior possible? yes: ok, no: no behavior can be found
		
		return ""
	
	
	func get_saved_behavior_for(entity) -> String:
		var default_behavior = get_default_behavior_for(entity)
		var behavior_group_name = _behavior_to_string(entity.behavior_group)
		
		return GlobalConfig.get_value("behavior", behavior_group_name, default_behavior)
	
	
	func get_default_behavior_for(entity) -> String:
		var group = entity.behavior_group
		# primary entity -> type
		# bäumen -> type/hacken -> BehaviorGroup
		# gegner -> type
		match typeof(entity.behavior_group):
			Entity.BehaviorGroup.ITEM:
				return "pickup"
			Entity.BehaviorGroup.MOB:
				return "attack"
			Entity.BehaviorGroup.NPC:
				return "talk"
			Entity.BehaviorGroup.PLAYER:
				return "none"
			Entity.BehaviorGroup.STRUCTURE:
				return "none"
			Entity.BehaviorGroup.RESOURCE:
				return "gather"
			_:
				return "none"


	func _behavior_to_string(behavior) -> String:
		match typeof(behavior):
			Entity.BehaviorGroup.ITEM:
				return "item"
			Entity.BehaviorGroup.MOB:
				return "mob"
			Entity.BehaviorGroup.NPC:
				return "npc"
			Entity.BehaviorGroup.PLAYER:
				return "player"
			Entity.BehaviorGroup.STRUCTURE:
				return "structure"
			Entity.BehaviorGroup.RESOURCE:
				return "resource"
			_:
				return "none"
