extends Spatial

var duration_ms: int = 5000
signal progress_completed

onready var bar = $SimpleBar
onready var update_tween = $UpdateTween

const _y_offset = 0.4

func _ready():
	update_tween.interpolate_property(bar, "percentage", 1.0, 0.0, duration_ms / 1000.0, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	update_tween.start()
	var y_pos = get_parent().get_aabb().size.y + _y_offset
	transform.origin = Vector3(0, y_pos, 0)


func _on_UpdateTween_tween_all_completed():
	emit_signal("progress_completed")
	queue_free()
