extends Spatial

var Item = load("res://mesh/items/Item.gd")

# This checks might very well be done inside the camera
# or can even be extracted to an own script.
# Terrain has nothing to do with movement. Maybe it should be on the player node.
const RAY_LENGTH = 100
const MAX_COLLISIONS = 5

# We need to collide with:
# - Terrain
# - Items
# - Buildings / Structures
# - Bestias
# TODO Adapt collision mask
const COLLISION_MASK = 32

var last_click = Vector2.ZERO

onready var pointer = get_node("../MoveCursor")
onready var player = get_node("../Player")
onready var camera = get_node("../Player/PlayerCamera")

func _physics_process(delta):
	if last_click == Vector2.ZERO:
		return
	
	var from = camera.project_ray_origin(last_click)
	var to = from + camera.project_ray_normal(last_click) * RAY_LENGTH
	last_click = Vector2.ZERO
	
	var space_state = get_world().direct_space_state
	var ignored_collisions = [player]
	var collisions = []
	
	for i in range(0, MAX_COLLISIONS):
		var result = space_state.intersect_ray(from, to, ignored_collisions)
		if result:
			print_debug("Raycast from: ", from, " to: ", to)
			print_debug("Hit at point: ", result.position)
			ignored_collisions.append(result.collider)
			collisions.append(result)
		else:
			break
	
	if collisions.size() > 0:
		print_debug("Found collisions: ", collisions.size())
		_handle_click(collisions)
		#pointer.translation = collisions[0].position
		#pointer.animate()
		#player.move_to(collisions[0].position)

func _handle_click(nodes):
	for node in nodes:
		print_debug(node.collider.get_class())
		if node.collider is Item:
			node.clicked()
		else:
			print_debug("No item")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		print_debug("_unhandled_input")
	#	last_click = event.position