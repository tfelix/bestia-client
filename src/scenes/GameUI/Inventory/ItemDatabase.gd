class_name ItemDatabase

const ITEM_DB_FILE = "res://scenes/Game/Entity/Item/item_database.json"

# Maybe do this by convention
var _item_infos = { }

func _init():
	_load_item_db()

func _load_item_db() -> void:
	var file = File.new()
	file.open(ITEM_DB_FILE, file.READ)
	var text = file.get_as_text()
	_item_infos = parse_json(text)
	file.close()


func get_data(item_id: int):
	var key = String(item_id)
	if not _item_infos.has(key):
		return null
	return _item_infos[key]
