extends Entity
class_name Player

# Emitted when the player movement has stopped.
# TODO Is this used? Can it be removed?
signal movement_stopped()
signal status_values_changed(changed_values)

var target: Vector3 = Vector3.INF
var can_move: bool = true

var destination = null
const GRAVITY = -9.81
const SPEED = 200

func _ready():
	PubSub.subscribe(PST.TERRAIN_CLICKED, self)
	PubSub.subscribe(PST.PLAYER_MOVE_REQUSTED, self)


func _physics_process(delta):
	if !can_move:
		destination = null
		return
	if translation != destination and destination != null:
		var gap = destination - translation
		# gap.y = 0
		gap = gap.normalized()

		var velocity = gap * SPEED * delta
		# velocity.y += delta * GRAVITY

		# move_and_slide(velocity, Vector3.UP)

		var angle = atan2(velocity.x, velocity.z)
		var player_rot = rotation
		player_rot.y = angle

		# Snap to target if we are close to destination
		if gap.length()  < 0.1:
			translation = Vector3(destination.x, translation.y, destination.z)
			destination = null
			emit_signal("movement_stopped")


func free():
  PubSub.unsubscribe(self)
  .free()


# TODO Later access the real mesh of the player
func get_aabb() -> AABB:
	return AABB(Vector3.ZERO, Vector3(1, 2.2, 1))


func move_to(destination):
	if !can_move:
		return
	$MoveIndicator.translation = destination
	$MoveIndicator.play()
	target = destination


func event_published(event_key, payload) -> void:
  match (event_key):
    PST.TERRAIN_CLICKED, PST.PLAYER_MOVE_REQUSTED:
      move_to(payload)