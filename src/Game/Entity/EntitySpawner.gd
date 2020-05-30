"""
Spawns entity nodes based on a visual component.
"""
class_name EntitySpawner

const FALLBACK_VISUAL_ENTITY = "res://Game/Entity/Item/Apple/Apple.tscn"
const ITEM_ENTITY_PATH = "res://Game/Entity/Item/%s/%s.tscn"

func spawn_entity(visual: String) -> Spatial:
	var visual_path = visual.split("/")
	assert(visual_path.size() == 2)
	var visual_type = visual_path[0].to_upper()
	var visual_name = visual_path[1].capitalize().replace(" ", "")
	var complete_path = ""
	if visual_type == "ITEM":
		complete_path = ITEM_ENTITY_PATH % [visual_name, visual_name]
	else:
		printerr("Unknown visual type: ", visual_type)
		return _spawn_fallback()
	
	var node = load(complete_path)
	if node == null:
		printerr("Could not load entity ", complete_path)
		return _spawn_fallback()
	
	return node.instance()


func _spawn_fallback() -> Spatial:
	var fallback = load(FALLBACK_VISUAL_ENTITY)
	assert(fallback != null)
	return fallback.instance()
