extends Node
"""
Handles the spawning of new enemyies when the game is
in the standalone mode.
"""
class_name FakeMobHandler

const player_entity_id = 1000
var _mob = {}

onready var _cast_timer = $CastTimer

func _init():
	GlobalEvents.connect("onEnemySpawned", self, "_register_spawned_enemy")


func _register_spawned_enemy(entity: Entity) -> void:
	_mob[entity.id] = entity


func take_damage(entity_id: int, damage: int) -> void:
	print_debug("Entity ", entity_id, " take damage: ", damage)
	if _mob.has(entity_id):
		var entity = _mob[entity_id]
		var cond_comp = entity.get_component(ConditionComponent.NAME) as ConditionComponent
		cond_comp.cur_health -= damage
		if cond_comp.cur_health <= 0:
			# Kill the enemy
			# We can not alter the component in place. We must actually copy it.
			var visual_comp = entity.get_component(VisualComponent.NAME)
			var update = ComponentData.new()
			update.data["animation"] = "die"
			update.entity_id = entity_id
			update.component_name = VisualComponent.NAME
			
			GlobalEvents.emit_signal("onMessageReceived", update)


func use_skill(msg: UseAttackMessage):
	if msg.player_attack_id == UseAttackMessage.RANGE_ATTACK_ID:
		var dmg_msg = DamageMessage.new()
		dmg_msg.entity_id = msg.target_entity
		dmg_msg.total_damage = randi() % 20 + 10
		
		var ranged_msg = RangedAttackMessage.new()
		ranged_msg.entity_id = player_entity_id
		ranged_msg.target_id = msg.target_entity
		ranged_msg.projectile = "arrow"
		ranged_msg.damage = dmg_msg
		ranged_msg.latency_ms = 10
		
		GlobalEvents.emit_signal("onMessageReceived", ranged_msg)
		take_damage(msg.target_entity, dmg_msg.total_damage)
		
	elif msg.player_attack_id == UseAttackMessage.MELEE_ATTACK_ID:
		# check if distance is ok and then let the attack be made
		print_debug("melee")
	else:
		# Cast the skill
		var cast_comp = ComponentData.new()
		cast_comp.data["cast_time"] = 400
		cast_comp.data["cast_db_name"] = "skill_fireball"
		cast_comp.data["target_entity_id"] = msg.target_entity
		cast_comp.entity_id = player_entity_id
		cast_comp.component_name = CastComponent.NAME
		GlobalEvents.emit_signal("onMessageReceived", cast_comp)
	
		# Setup the damage display later on
		_cast_timer.start(cast_comp.data["cast_time"] / 1000.0)
		yield(_cast_timer, "timeout")
		
		var cast_remove = ComponentRemoveMessage.new()
		cast_remove.component_name = CastComponent.NAME
		cast_remove.entity_id = player_entity_id
		GlobalEvents.emit_signal("onMessageReceived", cast_remove)
	
		var dmg_msg = DamageMessage.new()
		dmg_msg.entity_id = msg.target_entity
		dmg_msg.total_damage = randi() % 20 + 30
	
		var fx_msg = FxMessage.new()
		fx_msg.target_id = msg.target_entity
		fx_msg.fx = "fireball"
		fx_msg.damage = dmg_msg
		fx_msg.latency_ms = 10
		GlobalEvents.emit_signal("onMessageReceived", fx_msg)
