extends Resource
class_name ShortcutData

enum ShortcutType {
	ITEM,
	ATTACK
}

export(ShortcutType) var type
export var icon: Texture
export var payload = {}
