extends Spatial

onready var _crosses = $Crosses

var _damage: DamageMessage


func _trigger_damage_display() -> void:
	if _damage:
		GlobalEvents.emit_signal("onDamageReceived", _damage)


func _emit_particles() -> void:
	# workaround as its seems setting emission from animation player
	# has some issues and emission setting is kept on all the time
	_crosses.emitting = true


func start(target_entity: Entity, damage: DamageMessage) -> void:
	_damage = damage
