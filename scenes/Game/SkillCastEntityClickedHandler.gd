class_name SkillCastEntityClickedHandler

var player_attack_id

func _init(player_attack_id):
	self.player_attack_id = player_attack_id


func handler_installed() -> void:
	var cursor_change = CursorRequest.new()
	cursor_change.identifier = "cast_attack"
	cursor_change.type = Cursor.Type.ATTACK
	PubSub.publish(PST.CURSOR_CHANGE, cursor_change)


func handler_removed() -> void:
	PubSub.publish(PST.CURSOR_RESET, "cast_attack")


func on_entity_clicked(entity: Entity) -> void:
	var msg = UseAttackMessage.new()
	msg.player_attack_id = player_attack_id
	msg.target_entity = entity.id
	PubSub.publish(PST.SERVER_SEND, msg)