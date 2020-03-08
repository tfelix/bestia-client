extends Component
class_name NameComponent

const MobLabel = preload("res://scenes/GameUI/MobLabel/MobLabel.tscn")
const NAME = "NameComponent"

export(String) var entity_name

var _mob_label = null


func get_name() -> String:
	return NAME


func on_attach(entity) -> void:
	entity_id = entity.id
	_mob_label = MobLabel.instance()
	entity.get_spatial().add_child(_mob_label)
	_mob_label.set_mob_name(entity_name)
	_mob_label.visible = false


func on_remove(entity) -> void:
	if _mob_label != null:
		_mob_label.queue_free()
		_mob_label = null


func on_mouse_entered(entity) -> void:
	_mob_label.visible = true


func on_mouse_exited(entity) -> void:
	_mob_label.visible = false
