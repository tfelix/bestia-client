extends KinematicBody
class_name Player

const GRAVITY = -9.81
const SPEED = 200

var destination = null

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
	
func move_to(destination):
	self.destination = destination