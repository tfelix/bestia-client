"""
Handles the spawning of new enemyies when the game is
in the standalone mode.
"""
class_name FakeMobHandler

var _mob = {}

func _init():
	GlobalEvents.connect("onEnemySpawned", self, "_register_spawned_enemy")


func _register_spawned_enemy(entity: Entity) -> void:
	_mob[entity.id] = entity


func take_damage(entity_id: int, damage: int) -> void:
	print_debug("Entity ", entity_id, " take damage: ", damage)
	if _mob.has(entity_id):
		var entity = _mob[entity_id]
		# TODO subtract the damage and then control the entity
