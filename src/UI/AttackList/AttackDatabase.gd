class_name AttackDatabase


const ATTACK_DB_FILE = "res://UI/AttackList/attack_database.json"

var _attack_infos = { }


func _init():
	_load_attack_db()


func _load_attack_db() -> void:
	var file = File.new()
	assert(file.file_exists(ATTACK_DB_FILE))
	file.open(ATTACK_DB_FILE, file.READ)
	var text = file.get_as_text()
	_attack_infos = parse_json(text)
	file.close()


func get_data(attack: Dictionary) -> AttackData:
	var key = attack["database_name"]
	if not _attack_infos.has(key):
		return null
	var dict = _attack_infos[key]

	var res = AttackData.new()
	res.database_name = key
	res.element = dict["element"]
	res.mana = dict["mana"]
	
	res.attack_entity_id = attack["attack_entity_id"]
	res.level = attack["level"]
	
	return res
