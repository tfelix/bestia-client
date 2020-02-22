extends Spatial

var _selected_entity: Entity = null

onready var interactions: Interactions = get_parent().get_node("Interactions")

func _ready():
	GlobalEvents.connect("onEntitySelected", self, "_select_entity")


func _select_entity(entity: Entity) -> void:
	if entity == null:
		visible = false
		if interactions != null:
			interactions.abort_interaction()
	else:
		_selected_entity = entity
		global_transform.origin = entity.global_transform.origin


