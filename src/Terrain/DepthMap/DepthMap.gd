extends Viewport

onready var _ray_cast = $Camera/RayCast
onready var _depth_screen = $Camera/DepthScreen
onready var _camera = $Camera

export var target_ground_distance = 10

var current_ground_distance = 0


func _ready():
	_depth_screen.material_override.set_shader_param("camera_far_clip", _camera.far)


func _physics_process(delta):
	var terrain = _ray_cast.get_collider()
	if terrain == null:
		return
	# Collision in world space with the ground
	var collision_point_world = _ray_cast.get_collision_point()
	# We want to keep a local distance of 50 units
	var collision_point_local = _camera.to_local(collision_point_world)
	var pos_world = collision_point_world + Vector3(0.0, target_ground_distance, 0.0)
	_camera.global_transform.origin = pos_world
	# Export the variable so it can be used by other scripts
	current_ground_distance = pos_world.y
