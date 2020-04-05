extends Node


var _behavior_servce = BehaviorService.new()

func _ready():
	GlobalEvents.connect("onEntityClicked", self, "_on_entity_clicked")

# Checks what action should be performed on that entity. This basically means
# asking what the configured std. behavior is and then executing it.
func _on_entity_clicked(entity, click_event) -> void:
	var behavior = _behavior_servce.get_behavior_for(entity)
	match behavior:
		"attack":
			_attack_entity(entity)
		_:
			return


func _attack_entity(target_entity) -> void:
	GlobalEvents.emit_signal("onPlayerInteract", target_entity, "basic_attack")
