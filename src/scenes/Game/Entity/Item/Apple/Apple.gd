extends Item

onready var animation = $AnimationPlayer


func _on_Entity_component_updated(component: Component):
	if not component is VisualComponent:
		return
	
	var visual_component = component as VisualComponent
	
	if visual_component.animation == "spawn":
		animation.play("spawn")
		
