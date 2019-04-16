extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var MoveSpeed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var ui_right = Input.is_action_pressed("ui_right")
	var ui_left = Input.is_action_pressed("ui_left")
	
	var moveSpeed = 0
	
	if ui_right:
		moveSpeed = MoveSpeed
	elif ui_left:
		moveSpeed = -MoveSpeed
	
	set_axis_velocity(Vector2(moveSpeed, linear_velocity.y))
	
	pass
