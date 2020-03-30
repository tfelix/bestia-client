extends Spatial

export var point_radius = 0.25
export var ring_distance = 2.5
export var size: Vector2 = Vector2(50, 50)
export(float, 0.0, 1.0) var random_scale: float = 0.2

onready var _multi_mesh = $Grass
onready var _viewport = $GrassHideViewport
onready var _camera = $Camera


func _ready():
	#_position_grass()
	
	for i in range(_multi_mesh.multimesh.instance_count):
		var transform = Transform()
		var newPos = Vector3(randf() * size.x - size.x / 2, 0.0, randf() * size.y - size.y / 2)
		var scale_fac = rand_range(1.0 - random_scale, 1.0)
		var scale = Vector3(scale_fac, scale_fac, scale_fac)
		transform = transform.translated(newPos).scaled(scale)
		_multi_mesh.multimesh.set_instance_transform(i, transform)


func _position_grass() -> void:
	# Possibly we must go out further then only size/2
	var ac = Vector2(-size.x / 2.0, -size.y / 2.0) # Center of circle A
	var ar_base = 1.0 # Starting radius of circle A
	
	var bc = Vector2(-size.x / 2.0, size.y / 2.0) # Center of circle B
	var br_base = 1.0 # Starting radius of circle B

	var d_r = ring_distance * point_radius # Distance between concentric rings
	for radius_step_a in range(128):
		var a_r = ar_base + d_r * radius_step_a;
		for radius_step_b in range(128):
			var b_r = br_base + d_r * radius_step_b
			var red_radius_step_b = radius_step_b % 3
			var red_radius_step_a = radius_step_a % 3
			var use_ar = a_r + 0.0 if red_radius_step_b else 0.3 * d_r
			var use_br = b_r + 0.0 if red_radius_step_a else 0.3 * d_r
			
			# Intersect circle ac, use_ar and bc, use_br
			# Add the resulting points if they are within the pattern bounds 
			# (the bounds were [[-1,1]] on both axes for all prior screenshots)
			


func _process(delta):
	var tex = _viewport.get_texture()
	var material = _multi_mesh.multimesh.mesh.surface_get_material(0)
	material.set_shader_param("hide_texture", tex)
	material.set_shader_param("camera_position", _camera.global_transform.origin)
