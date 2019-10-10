class_name ItemModel

enum ItemType {
	USABLE,
	EQUIP,
	ETC
}

var image: Texture
var database_name: String = ""
var weight: int = 10
var amount: int = 1
var type = ItemType.USABLE

func totalWeight():
	return weight * amount

static func database_name_to_path(database_name: String) -> String:
	var base_path = "res://scenes/Game/Entity/Item/"
	var cleaned_db_name = database_name.capitalize().replace(" ", "")
	
	return base_path + cleaned_db_name

static func database_name_to_image_path(database_name: String) -> String:
	var item_path = database_name_to_path(database_name)
	var cleaned_db_name = database_name.capitalize().replace(" ", "")
	
	return item_path + "/" + cleaned_db_name + ".png"
