extends Component
class_name CastComponent

const CastingFx = preload("res://scenes/Fx/CastingFx/CastingFx.tscn")
const CastTargetMarker = preload("res://scenes/Game/CastTargetMarker/CastTargetMarker.tscn")
const CastBar = preload("res://scenes/GameUI/CastBar/CastBar.tscn")

const NAME = "CastComponent"

var cast_time: int
var cast_db_name: String
var target_entity_id: int
var target_area: Vector2

var _cast_bar
var _cast_fx
var _cast_marker

func get_name() -> String:
	return NAME


func on_attach(entity) -> void:
	var player = Global.entities.get_player_entity()
	_cast_fx = CastingFx.instance()
	player.add_child(_cast_fx)
	
	_cast_bar = CastBar.instance()
	_cast_bar.init("Fireball", 400, player)
	
	
	var target_entity = Global.entities.get_entity(target_entity_id)
	# Cast marker is able to delete itself so we must keep a weakref to
	# avoid double free calls.
	_cast_marker = weakref(CastTargetMarker.instance())
	_cast_marker.get_ref().init(target_entity)


func on_remove(entity) -> void:
	if _cast_fx != null:
		_cast_fx.queue_free()
		_cast_fx = null
	if _cast_marker != null:
		var marker_ref = _cast_marker.get_ref()
		if marker_ref:
			marker_ref.queue_free()
	if _cast_bar != null:
		_cast_bar.queue_free()