extends Component
class_name CastComponent

const CastingFx = preload("res://VFX/CastingFx/CastingFx.tscn")
const CastBar = preload("res://UI/CastBar/CastBar.tscn")
const CastTargetMarker = preload("res://Game/CastTargetMarker/CastTargetMarker.tscn")

const NAME = "CastComponent"

var cast_time := 0
var cast_db_name := ""

var _cast_bar
var _cast_fx
var _cast_marker

func get_name() -> String:
	return NAME


func on_attach(entity) -> void:
	_cast_fx = CastingFx.instance()
	entity.add_child(_cast_fx)


func on_update(entity, component_data) -> void:
	_cast_bar = CastBar.instance()
	_cast_bar.init("Fireball!", 400, entity)
	var target_entity_id = component_data.data["target_entity_id"]
	
	var target_entity = GlobalData.entities.get_entity(target_entity_id)
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
		_cast_bar = null
