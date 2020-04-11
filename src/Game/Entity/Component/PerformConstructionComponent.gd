extends Component
class_name PerformConstructionComponent

const NAME = "PerformConstructionComponent"

const ConstructionBar = preload("res://UI/ConstructionBar/ConstructionBar.tscn")

var label: String = ""
var duration_ms: int = 1000
var progress_ms: int = 0

var _bar: Node

func get_name() -> String:
	return NAME


func on_attach(entity) -> void:
	_bar = ConstructionBar.instance()
	entity.add_child(_bar, true)
	_bar.set_progress(progress_ms, duration_ms)
	_bar.set_label(label)


func on_remove(entity) -> void:
	if _bar != null:
		_bar.queue_free()
		_bar = null
