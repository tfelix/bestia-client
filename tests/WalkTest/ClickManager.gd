extends Node


func _ready():
	GlobalEvents.connect("onEntityClicked", self, "_on_entity_clicked")

# Checks what action should be performed on that entity. This basically means
# asking what the configured std. behavior is and then executing it.
func _on_entity_clicked(entity, click_event) -> void:
	attack_entity(entity)
	pass


func attack_entity(target_entity) -> void:
	if target_entity.entity_kind != Entity.EntityKind.MOB:
		return
	
	GlobalEvents.emit_signal("onPlayerInteract", target_entity, "basic_attack")
