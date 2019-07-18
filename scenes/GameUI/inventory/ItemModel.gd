enum ItemType {
	USABLE,
	EQUIP,
	ETC
}

class ItemModel:
	var icon: Texture
	var name: String = "undefined"
	var weight: int = 10
	var amount: int = 1
	var stackable: bool = true
	var type = ItemType.USABLE
	
	func totalWeight():
		return weight * amount