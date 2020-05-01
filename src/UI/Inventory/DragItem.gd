extends Control


var data: ItemData

onready var _item = $Item

func _ready():
	_item.texture = data.image
