class_name AttackData

var database_name: String
var attack_id: int
var attack_entity_id: int
var mana: int
var element: String
var level: int

var tr_name: String setget ,_get_tr_name
var tr_description: String setget ,_get_tr_description
var icon: Resource setget ,_get_icon

var _loaded_icon: Resource

const _placeholder_icon = "res://UI/AttackList/icons/placeholder.png"


func _get_icon() -> Resource:
	if _loaded_icon != null:
		return _loaded_icon
	
	var icon_path = "res://UI/AttackList/icons/%s.png" % database_name
	var loaded_icon = load(icon_path)
	
	if loaded_icon != null:
		_loaded_icon = loaded_icon
		return loaded_icon

	return load(_placeholder_icon)


func _get_tr_name() -> String:
	return tr(database_name)


func _get_tr_description() -> String:
	return tr(database_name + "_DESC")
