extends Node


var _behavior_servce = BehaviorService.new()

enum State {
	CAST_SELECTION,
	DEFAULT
}

var _current_state = State.DEFAULT
var _casted_attack

"""
Maybe it would be smart to handle centrally all clicks here e.g. also 
the on terrain click not inside the player but instead here.
"""
func _ready():
	GlobalEvents.connect("onEntityClicked", self, "_on_entity_clicked")
	GlobalEvents.connect("onCastSelectionStarted", self, "_on_cast_started")
	GlobalEvents.connect("onCastSelectionEnded", self, "_on_cast_ended")


func _on_cast_started(attack) -> void:
	_current_state = State.CAST_SELECTION
	_casted_attack = attack


func _on_cast_ended() -> void:
	_current_state = State.DEFAULT
	_casted_attack = null


# Checks what action should be performed on that entity. This basically means
# asking what the configured std. behavior is and then executing it.
func _on_entity_clicked(entity, click_event) -> void:
	match(_current_state):
		State.CAST_SELECTION:
			_cast_on_entity(entity)
		State.DEFAULT:
			# Get the default behavior for this entity and execute it.
			# TODO improve behavior
			var behavior = _behavior_servce.get_behavior_for(entity)
			match behavior:
				"attack":
					_attack_entity(entity)
				_:
					return


func _cast_on_entity(entity) -> void:
	print_debug("cast on entity")
	var msg = UseAttackMessage.new()
	msg.player_attack_id = _casted_attack
	msg.target_entity = entity.id
	GlobalEvents.emit_signal("onMessageSend", msg)
	GlobalEvents.emit_signal("onSkillCasted", _casted_attack, entity, null)
	GlobalEvents.emit_signal("onCastSelectionEnded")


func _attack_entity(target_entity) -> void:
	GlobalEvents.emit_signal("onPlayerInteract", target_entity, "basic_attack")
