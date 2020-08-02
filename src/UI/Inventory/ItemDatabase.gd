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
	res.visual = dict["visual"]
	match dict["type"]:
		"consumeable":
			res.type = ItemData.ItemType.CONSUMEABLE
		"structure":
			res.type = ItemData.ItemType.STRUCTURE
		"equip":
			res.type = ItemData.ItemType.EQUIP
		_:
			res.type = ItemData.ItemType.ETC
	match dict["slot"]:
		"head":
			res.equip_slot = ItemData.EquipSlot.HEAD
		"body":
			res.equip_slot = ItemData.EquipSlot.BODY
		"shoulder":
			res.equip_slot = ItemData.EquipSlot.SHOULDER
		"arms":
			res.equip_slot = ItemData.EquipSlot.ARMS
		"hands":
			res.equip_slot = ItemData.EquipSlot.HANDS
		"accessory_1":
			res.equip_slot = ItemData.EquipSlot.ACCESSORY_1
		"accessory_2":
			res.equip_slot = ItemData.EquipSlot.ACCESSORY_2
		"legs":
			res.equip_slot = ItemData.EquipSlot.LEGS
		"shoes":
			res.equip_slot = ItemData.EquipSlot.SHOES
		"weapon":
			res.equip_slot = ItemData.EquipSlot.WEAPON
		"shield":
			res.equip_slot = ItemData.EquipSlot.SHIELD
		"ammunition":
			res.equip_slot = ItemData.EquipSlot.AMMUNITION
		"none":
			res.equip_slot = ItemData.EquipSlot.NONE
		_:
			printerr("Unknown equip slot: ", dict["slot"])

	return res
