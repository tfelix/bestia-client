"""
The ClickManager decides the actions to take when the player has clicked
on something. It is the central instance which can overwrite the click behavior.
"""
extends Node

var _interaction_servce = InteractionService.new()

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
	GlobalEvents.connect("onTerrainClicked", self, "_on_terrain_clicked")
	GlobalEvents.connect("onEntityClicked", self, "_on_entity_clicked")
	GlobalEvents.connect("onCastSelectionStarted", self, "_on_castselection_started")
	GlobalEvents.connect("onCastSelectionEnded", self, "_on_castselection_ended")


func _on_terrain_clicked(global_pos) -> void:
	_interaction_servce.hide_behavior_selection()
	GlobalEvents.emit_signal("terrain_clicked", global_pos)


func _on_castselection_started(attack) -> void:
	_current_state = State.CAST_SELECTION
	_casted_attack = attack


func _on_castselection_ended() -> void:
	_current_state = State.DEFAULT
	_casted_attack = null


# Checks what action should be performed on that entity. This basically means
# asking what the configured std. behavior is and then executing it.
func _on_entity_clicked(entity: Entity, click_event: InputEventMouseButton) -> void:
	match(_current_state):
		State.CAST_SELECTION:
			GlobalEvents.emit_signal("onSkillCasted", _casted_attack, entity, null)
			GlobalEvents.emit_signal("onCastSelectionEnded")
		State.DEFAULT:
			# Check if there is a default behavior for the clicked entity,
			# if not open the menu or if the override condition is met e.g. long
			# click on entity has happened.
			if click_event.is_action_pressed(Actions.ACTION_LEFT_CLICK) and click_event.control:
				_interaction_servce.show_behavior_selection(entity)
			else:
				# Get the default behavior for this entity and execute it.
				_interaction_servce.hide_behavior_selection()
				var interaction = _interaction_servce.get_behavior_for(entity)
				match interaction:
					"pickup":
						GlobalEvents.emit_signal("onPlayerItemPicked", entity)
					"attack":
						GlobalEvents.emit_signal("onPlayerAttacked", entity)
					"use":
						GlobalEvents.emit_signal("onPlayerUsed", entity)
					_:
						return

