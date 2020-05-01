class_name ItemDatabase

const ITEM_DB_FILE = "res://Game/Entity/Item/item_database.json"

var _item_infos = { }


func _init():
	_load_item_db()


func _load_item_db() -> void:
	var file = File.new()
	assert(file.file_exists(ITEM_DB_FILE))
	file.open(ITEM_DB_FILE, file.READ)
	var text = file.get_as_text()
	_item_infos = parse_json(text)
	file.close()


func get_data(item_id: int) -> ItemData:
	var key = String(item_id)
	if not _item_infos.has(key):
		return null
	var dict = _item_infos[key]
	var data = _dict_to_res(dict)
	data.item_id = item_id
	
	return data


func _dict_to_res(dict) -> ItemData:
	var res = ItemData.new()
	res.database_name = dict["database_name"]
	res.weight = dict["weight"]
	match dict["type"]:
		"consumeable":
			res.type = ItemData.ItemType.CONSUMEABLE
		"structure":
			res.type = ItemData.ItemType.STRUCTURE
		"equip":
			res.type = ItemData.ItemType.EQUIP
		_:
			res.type = ItemData.ItemType.ETC
	return res
