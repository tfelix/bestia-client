extends Spatial

enum MobState {
	IDLE,
	SEARCHING,
	AGGRO,
	MOVING
}

export var enabled = true
export var speed = 3.0

var _state = MobState.IDLE
var _target_player: Spatial = null

onready var entity = $Entity
onready var _player_detector = $PlayerDetector
onready var _animation = $AnimationPlayer 
onready var _timer = $StateTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	if not enabled:
		_timer.stop()
	GlobalEvents.emit_signal("onEnemySpawned", entity)


func _physics_process(delta):
	var player = _player_detector.get_collider()
	if player == null:
		return
	if _state != MobState.AGGRO && enabled:
		_animation.play("aggro")
		_player_detector.enabled = false
		_state = MobState.AGGRO
		_target_player = player


func _on_StateTimer_timeout():
	if _state == MobState.IDLE:
		_animation.play("search")
		_state = MobState.SEARCHING
	elif _state == MobState.SEARCHING:
		_state = MobState.MOVING
		# perform random move
	elif _state == MobState.MOVING:
		_state = MobState.IDLE
		_timer.wait_time = 2
		_timer.start()



func _on_Entity_component_updated(component):
	if component.get_name() == VisualComponent.NAME:
		pass
		#if component.animaton == "die":
		#	enabled = false
		#	_timer.stop()
