class_name AttackData

var database_name: String
var attack_id: int
var attack_entity_id: int
var mana: int
var element: String
var level: int

var tr_name: String setget ,_get_tr_name
var tr_description: String setget ,_get_tr_description


func _get_tr_name() -> String:
	return tr(database_name)


func _get_tr_description() -> String:
	return tr(database_name + "_DESC")

