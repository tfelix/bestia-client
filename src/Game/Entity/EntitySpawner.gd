"""
Spawns entity nodes based on a visual component.
"""
class_name EntitySpawner

const ITEM_ENTITY_PATH = "res://Game/Entity/Item/%s/%s.tscn"

func spawn_entity(visual: VisualComponent) -> Spatial:
	var visual_path = visual.visual.split("/")
	assert(visual_path.size() == 2)
	var visual_type = visual_path[0].to_upper()
	var visual_name = visual_path[1].capitalize()
	var complete_path = ""
	if visual_type == "ITEM":
		complete_path = ITEM_ENTITY_PATH % [visual_name, visual_name]
	else:
		printerr("Unknown visual type: ", visual_type)
		return null
	
	var node = load(complete_path)
	if node == null:
		printerr("Could not load entity ", complete_path)
		return null
	
	return node.instance()
