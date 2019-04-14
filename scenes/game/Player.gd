extends KinematicBody

export var player_name = "rocket"

var speed = 200
var spin = 0.5
var direction = Vector3()
var destination = null

func _physics_process(delta):
	if translation != destination and destination != null:
		var gap = destination - translation
		var velocity = gap.normalized() * speed * delta
		move_and_slide(velocity, Vector3.UP)
		
		var angle = atan2(velocity.x, velocity.z)
		var player_rot = rotation
		player_rot.y = angle
		# rotation = player_rot
		
		# Snap to target if we are close to destination
		if gap.length()  < 0.1:
			translation = Vector3(destination.x, translation.y, destination.z)
			destination = null
	
func move_to(destination):
	self.destination = destination