extends Control

onready var _label = $ConstructionBar/Header/Label
onready var _progress = $ConstructionBar/ProgressBar

var _current: float = 0
var _total: float = 1000

var _parent: Entity
var _cam

func _ready():
	_parent = get_parent()
	_cam = get_tree().get_root().get_camera()

func set_progress(current: int, total: int) -> void:
	_current = current
	_total = total


func set_label(text: String) -> void:
	_label.text = "Construction: %s" % text


func _process(delta):
	var pos = _parent.global_transform.origin
	var viewport_pos = _cam.unproject_position(pos)
	self.set_position(viewport_pos)

	_current += delta * 1000
	var x = _current / _total
	_progress.value = x * 100


func _on_Cancel_pressed():
	# Cancel the component
	pass # Replace with function body.
