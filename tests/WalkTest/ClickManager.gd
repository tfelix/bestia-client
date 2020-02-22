extends Node


func _ready():
	GlobalEvents.connect("onEntityClicked", self, "_on_entity_clicked")

# Checks what action should be performed on that entity. This basically means
# asking what the configured std. behavior is and then executing it.
func _on_entity_clicked(entity: Entity) -> void:
	pass

