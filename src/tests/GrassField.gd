extends Spatial

export var point_radius = 0.25 # 0.25
export var ring_distance = 6 #2.5
export var size: Vector2 = Vector2(50, 50)
export(float, 0.0, 1.0) var random_scale: float = 0.2

onready var _multi_mesh = $Grass
onready var _viewport = $GrassHideViewport
onready var _camera = $Camera


func _ready():
	var points = _position_grass()
	_multi_mesh.multimesh.instance_count = points.size()
	
	for i in range(points.size()):
		var transform = Transform()
		var p = points[i]
		var newPos = Vector3(p.x, 0.0, p.y)
		var scale_fac = 0.8 # rand_range(1.0 - random_scale, 1.0)
		var scale = Vector3(scale_fac, scale_fac, scale_fac)
		#transform = transform.translated(newPos)
		# .rotated(Vector3.UP, rand_range(0.0, 3.14))
		transform = transform.translated(newPos)
		_multi_mesh.multimesh.set_instance_transform(i, transform)


func _position_grass():
	# Possibly we must go out further then only size/2
	var hsx = size.x / 2.0
	var hsy = size.y / 2.0
	
	var ac = Vector2(-hsx - 15, -hsy) # Center of circle A
	var ar_base = point_radius # Starting radius of circle A
	
	var bc = Vector2(-hsx - 15, hsy) # Center of circle B
	var br_base = point_radius # Starting radius of circle B
	
	var points = []

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
			var d = ac.distance_to(bc)
			if d > a_r + b_r:
				# No solution, circles not touching
				continue
			if d < abs(a_r - b_r):
				# No solution, circles contained in each other
				continue
			if d == 0 and a_r == b_r:
				# Circles are the same, infinite solutions
				continue
			var a = (pow(a_r, 2) - pow(b_r, 2) + pow(d, 2)) / (2*d)
			var h = sqrt(pow(a_r, 2) - pow(a, 2))
			var p2 = ac + a * (bc - ac) / d
			
			var x3_a = p2.x + h * (bc.y - ac.y) / d
			var y3_a = p2.y - h * (bc.x - bc.x) / d
			var x3_b = p2.x - h * (bc.y - ac.y) / d
			var y3_b = p2.y + h * (bc.x - bc.x) / d
			
			# Intersecting points must be shifted back to right coordiantes
			# Add the resulting points if they are within the pattern bounds 
			var ip1 = Vector2(x3_a, y3_a)
			var ip2 = Vector2(x3_b, y3_b)
			if abs(ip1.x) <= hsx and abs(ip1.y) <= hsy:
				points.append(ip1)
			if abs(ip2.x) <= hsx and abs(ip2.y) <= hsy:
				points.append(ip2)
	return points


func _process(delta):
	var tex = _viewport.get_texture()
	var material = _multi_mesh.multimesh.mesh.surface_get_material(0)
	# I am not sure why the texture must be manually set. It should work when
	# set via shader texture but it does not. Godot Bug?
	material.set_shader_param("hide_texture", tex)
	material.set_shader_param("camera_position", _camera.global_transform.origin)
