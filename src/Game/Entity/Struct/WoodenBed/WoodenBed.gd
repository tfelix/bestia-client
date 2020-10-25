extends Spatial


onready var _stand_up_ui = $SpatialFollower/Button
onready var _player = $Mannequiny


func _on_Entity_used(player_entity):
	_stand_up_ui.visible = true
	_player.visible = true
	player_entity.hide()
