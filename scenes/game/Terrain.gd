extends MeshInstance

# This checks might very well be done inside the camera
# or can even be extracted to an own script.
# Terrain has nothing to do with movement. Maybe it should be on the player node.
const RAY_LENGTH = 100

# We need to collide only with terrain which is on layer 6
const COLLISION_MASK = 32

var last_click = Vector2.ZERO

onready var pointer = get_tree().get_root().get_node("Game/MoveCursor")
onready var player = get_tree().get_root().get_node("Game/Player")
onready var ball = get_tree().get_root().get_node("Game/Pointer")
onready var camera = get_tree().get_root().get_node("Game/Player/PlayerCamera")

func _physics_process(delta):
	if last_click == Vector2.ZERO:
		return
	# This I think can be run inside the input handler. Only the raycast query should be
	# placed here.
	
	var from = camera.project_ray_origin(last_click)
	var to = from + camera.project_ray_normal(last_click) * RAY_LENGTH
	
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [player])
	last_click = Vector2.ZERO
	
	if result:
		print("Raycast from: ", from, "to: ", to)
		print(result.collider.name)
		pointer.translation = result.position
		pointer.animate()
		print("Hit at point: ", result.position)
		player.move_to(result.position)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		last_click = event.position
	#if event is InputEventMouseMotion:
		#last_pos = event.position