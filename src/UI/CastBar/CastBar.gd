extends Control

onready var _perc_tween = $TweenCastPerc
onready var _text = $VBox/Text
onready var _bar = $VBox/CenterContainer/Bar

var _entity
var _progress = 0.0

var _cast_text = "SKILL_NAME" 
var _duration = 1000


func _ready() -> void:
	_text.text = _cast_text
	_perc_tween.interpolate_property(
		self,
		"_progress",
		0.0,
		1.0,
		_duration / 1000.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	_perc_tween.start()


func init(cast_text: String, cast_duration_ms: int, parent: Spatial) -> void:
	_duration = cast_duration_ms
	_cast_text = cast_text
	_entity = parent
	parent.add_child(self)
	_update_position()


func _process(delta) -> void:
	_bar.set_value(_progress)
	_update_position()


func _update_position():
	var aabb = _entity.get_aabb()
	var entity_pos = _entity.global_transform.origin
	var camera = get_tree().get_root().get_camera()
	var node_height = aabb.size.y + 0.8
	var pos = camera.unproject_position(entity_pos + Vector3(0.0, node_height, 0.0))
	set_position(pos)
