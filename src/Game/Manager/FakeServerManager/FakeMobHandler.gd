extends Node
"""
Handles the spawning of new enemyies when the game is
in the standalone mode.
"""
class_name FakeMobHandler

# better handle this in a unique and single place
const player_entity_id = 1
var _mob = {}

onready var _cast_timer = $CastTimer

func _init():
	GlobalEvents.connect("entity_spawned", self, "_register_spawned_enemy")


func _register_spawned_enemy(entity: Entity) -> void:
	# We must check if the entity is actually an enemy. Accessing
	# the parent is a crude hack and usually should be avoided.
	if entity.get_parent() is Testor:
		_mob[entity.id] = entity


func take_damage(entity_id: int, damage: int) -> void:
	print_debug("Entity ", entity_id, " takes damage: ", damage)
	if _mob.has(entity_id):
		var cond_comp = _mob[entity_id]
		cond_comp.cur_health -= damage
		if cond_comp.cur_health <= 0:
			# Kill the enemy
			var visual_comp = VisualComponent.new()
			visual_comp.animation = "die"
			visual_comp.entity_id = entity_id
			
			GlobalEvents.emit_signal("onMessageReceived", visual_comp)


func _can_attack_entity(entity_id: int) -> bool:
	var entity = GlobalData.entities.get_entity(entity_id)
	if entity == null:
		return false
	
	var cond_comp = entity.get_component(ConditionComponent.NAME) as ConditionComponent
	if cond_comp == null:
		return false
	
	if cond_comp.cur_health <= 0:
		return false

	return true


func use_skill(msg: UseAttackMessage) -> void:
	if not _can_attack_entity(msg.target_entity):
		return
	
	if msg.player_attack_id == UseAttackMessage.RANGE_ATTACK_ID:
		_use_ranged_attack(msg.target_entity)
	elif msg.player_attack_id == UseAttackMessage.MELEE_ATTACK_ID:
		# check if distance is ok and then let the attack be made
		print_debug("melee")
	else:
		_use_skill_attack(msg.target_entity)


func _use_ranged_attack(target_entity_id: int) -> void:
	var dmg_msg = DamageMessage.new()
	dmg_msg.entity_id = target_entity_id
	dmg_msg.total_damage = randi() % 20 + 10
	dmg_msg.type = DamageMessage.DamageType.DAMAGE
	
	var chance = randf()
	if chance > 0.9:
		dmg_msg.total_damage *= 1.5
		dmg_msg.type = DamageMessage.DamageType.CRIT
	elif chance < 0.2:
		dmg_msg.total_damage = 0
		dmg_msg.type = DamageMessage.DamageType.MISS
	
	var ranged_msg = RangedAttackMessage.new()
	ranged_msg.entity_id = player_entity_id
	ranged_msg.target_id = target_entity_id
	ranged_msg.projectile = "arrow"
	ranged_msg.damage = dmg_msg
	ranged_msg.latency_ms = 10
	
	GlobalEvents.emit_signal("onMessageReceived", ranged_msg)
	take_damage(target_entity_id, dmg_msg.total_damage)


func _use_skill_attack(target_entity_id: int) -> void:
	# Cast the skill
	var cast_comp = CastComponent.new()
	cast_comp.cast_time_ms = 4000
	cast_comp.cast_db_name = "skill_fireball"
	cast_comp.target_entity_id = target_entity_id
	cast_comp.entity_id = player_entity_id
	GlobalEvents.emit_signal("onMessageReceived", cast_comp)


	# Setup the damage display later on
	_cast_timer.start(cast_comp.data["cast_time"] / 1000.0)
	yield(_cast_timer, "timeout")
	
	var cast_remove = ComponentRemoveMessage.new()
	cast_remove.component_name = "cast"
	cast_remove.entity_id = player_entity_id
	GlobalEvents.emit_signal("onMessageReceived", cast_remove)

	var dmg_msg = DamageMessage.new()
	dmg_msg.entity_id = target_entity_id
	dmg_msg.total_damage = 1 # wrandi() % 20 + 30

	var fx_msg = FxMessage.new()
	fx_msg.target_id = target_entity_id
	fx_msg.fx = "fireball" # TODO Insert actual used skill here
	fx_msg.damage = dmg_msg
	fx_msg.latency_ms = 10
	GlobalEvents.emit_signal("onMessageReceived", fx_msg)
	take_damage(target_entity_id, dmg_msg.total_damage)
