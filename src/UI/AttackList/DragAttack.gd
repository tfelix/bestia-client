extends Control


var data: AttackData

onready var _attack = $Attack

func _ready():
	_attack.texture = data.image
