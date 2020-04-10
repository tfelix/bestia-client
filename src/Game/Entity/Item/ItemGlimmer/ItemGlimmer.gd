extends Spatial

onready var _player = $AnimationPlayer

func _ready():
	_player.play("glimmer")
