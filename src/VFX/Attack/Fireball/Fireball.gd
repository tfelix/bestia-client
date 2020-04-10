extends Spatial

var _hit_damage: DamageMessage

func _on_HitArea_body_entered(body) -> void:
	print_debug("has hit!")


func _trigger_damage() -> void:
	if _hit_damage:
		GlobalEvents.emit_signal("onDamageReceived", _hit_damage)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()


func start(target_entity: Entity, damage: DamageMessage) -> void:
	_hit_damage = damage
