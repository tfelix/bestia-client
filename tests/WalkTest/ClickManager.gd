extends Node


func _ready():
	GlobalEvents.connect("onEntityClicked", self, "_on_entity_clicked")

# Checks what action should be performed on that entity. This basically means
# asking what the configured std. behavior is and then executing it.
func _on_entity_clicked(entity, click_event) -> void:
	attack(entity)
	pass


func attack(target_entity) -> void:
	if target_entity.entity_kind != Entity.EntityKind.MOB:
		return
	# what basic attack is done?
	# ranged
	# send msg to server
	var atk_msg = UseAttackMessage.new()
	atk_msg.player_attack_id = UseAttackMessage.RANGE_ATTACK_ID
	atk_msg.target_entity = target_entity.id
	GlobalEvents.emit_signal("onSendToServer", atk_msg)
	# wait for response and dmg
	# play animation
