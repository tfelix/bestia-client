extends Spatial

var _hit_damage: DamageMessage
onready var _smoke = $Smoke


func _trigger_damage() -> void:
	_smoke.emitting = true
	if _hit_damage:
		GlobalEvents.emit_signal("onDamageReceived", _hit_damage)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


func start(target_entity: Entity, damage: DamageMessage) -> void:
	_hit_damage = damage
