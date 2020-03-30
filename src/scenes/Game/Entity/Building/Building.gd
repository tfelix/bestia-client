extends Spatial

# Probably this must be hidden inside a component
var _building_id = "test-1234-1234"

onready var _animation = $AnimationPlayer


func _ready():
	GlobalEvents.connect("onBuildingEntered", self, "_hideSightBlockingElements")
	GlobalEvents.connect("onBuildingExit", self, "_showSightBlockingElements")


func _hideSightBlockingElements(building_id: String) -> void:
	if building_id != _building_id:
		return
	_animation.play("hide_sighblocking")


func _showSightBlockingElements(building_id: String) -> void:
	if building_id != _building_id:
		return
	_animation.play_backwards("hide_sighblocking")


func _on_IndoorArea_body_entered(body):
	GlobalEvents.emit_signal("onBuildingEntered", _building_id)


func _on_IndoorArea_body_exited(body):
	GlobalEvents.emit_signal("onBuildingExit", _building_id)
