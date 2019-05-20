extends KinematicBody
class_name Player

var PST = load("res://PubSubTopics.gd")

const GRAVITY = -9.81
const SPEED = 200

var destination = null

# Emitted when the player movement has stopped.
signal movement_stopped()

func _ready():
  PubSub.subscribe(PST.TERRAIN_CLICKED, self)
  PubSub.subscribe(PST.PLAYER_MOVE_REQUSTED, self)

func free():
  PubSub.unsubscribe(self)
  .free()

func _physics_process(delta):
	if translation != destination and destination != null:
		var gap = destination - translation
		# gap.y = 0
		gap = gap.normalized()

		var velocity = gap * SPEED * delta
		# velocity.y += delta * GRAVITY

		move_and_slide(velocity, Vector3.UP)

		var angle = atan2(velocity.x, velocity.z)
		var player_rot = rotation
		player_rot.y = angle

		# Snap to target if we are close to destination
		if gap.length()  < 0.1:
			translation = Vector3(destination.x, translation.y, destination.z)
			destination = null
			emit_signal("movement_stopped")

func move_to(destination):
	self.destination = destination
	$MoveIndicator.translation = destination
	$MoveIndicator.play()

func event_published(event_key, payload):
  match (event_key):
    PST.TERRAIN_CLICKED, PST.PLAYER_MOVE_REQUSTED:
      move_to(payload)