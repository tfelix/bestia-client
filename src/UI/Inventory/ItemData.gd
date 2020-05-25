extends Resource
class_name ItemData

const PLACEHOLDER_IMG = preload("res://UI/Inventory/item_placeholder.png")

enum ItemType {
	CONSUMEABLE,
	STRUCTURE,
	EQUIP,
	ETC
}

export var database_name: String setget _set_database_name
export(ItemType) var type = ItemType.ETC
export var weight: int = 0
export var item_id: int = 0
export var amount: int = 0
export var player_item_id: int = 0
export var image: Texture
export var visual: String

var tr_database_name: String setget ,_get_tr_database_name
var tr_description: String setget ,_get_tr_description


"""
Returns true if the user can use an item. This is true for several item types.
"""
func is_usable() -> bool:
	return type == ItemType.CONSUMEABLE || type == ItemType.EQUIP || type == ItemType.STRUCTURE


func _set_database_name(new_value: String) -> void:
	database_name = new_value
	var image_path = _database_name_to_image_path(database_name)
	image = load(image_path)
	if image == null:
		image = PLACEHOLDER_IMG


func _database_name_to_image_path(_database_name: String) -> String:
	var base_path = "res://Game/Entity/Item/"
	var cleaned_db_name = _database_name.capitalize().replace(" ", "")
	
	return base_path + cleaned_db_name + "/" + cleaned_db_name + ".png"


func _get_tr_database_name() -> String:
	return tr(database_name.to_upper())


func _get_tr_description() -> String:
	return tr((database_name + "_description").to_upper())
