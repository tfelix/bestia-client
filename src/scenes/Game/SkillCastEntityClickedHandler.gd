class_name SkillCastEntityClickedHandler

var player_attack_id

func _init(player_attack_id):
	self.player_attack_id = player_attack_id


func handler_installed() -> void:
	GlobalEvents.emit_signal("onCastStarted", player_attack_id)


func handler_removed() -> void:
	GlobalEvents.emit_signal("onCastEnded", player_attack_id)


func on_entity_clicked(entity: Entity) -> void:
	var msg = UseAttackMessage.new()
	msg.player_attack_id = player_attack_id
	msg.target_entity = entity.id
	GlobalEvents.emit_signal("onMessageSend", msg)
