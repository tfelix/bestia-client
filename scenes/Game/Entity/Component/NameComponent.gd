extends Node
class_name NameComponent

var MobLabel = preload("res://scenes/GameUI/MobLabel/MobLabel.tscn")

export(String) var entity_name

var _mob_label = null

func on_attach(entity) -> void:
	_mob_label = MobLabel.instance()
	entity.add_child(_mob_label)
	_mob_label.visible = false


func on_remove(entity) -> void:
	if _mob_label != null:
		_mob_label.queue_free()
		_mob_label = null


func on_mouse_entered(entity) -> void:
	_mob_label.visible = true


func on_mouse_exited(entity) -> void:
	_mob_label.visible = false
