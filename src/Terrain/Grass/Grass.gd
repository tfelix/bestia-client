extends Spatial

export var size: Vector2 = Vector2(25, 25)

"""
This is the grass instance by unit
"""
export var grass_density: int = 8

"""
Heightmap of the terrain. The generated grass will use this height information
in order to be placed at the correct height. Also the 
"""
export var height_map: Texture
"""
Contains the heightmap zero in world coordinates. This is needed to interpret
the information from the grayscale texture.
"""
export(float) var heightmap_zero: float 

onready var _multi_mesh = $Grass
onready var _viewport = $GrassHideViewport

func _ready():
	var point_count = size.x * size.y * grass_density
	_multi_mesh.multimesh.instance_count = point_count
	
	for i in range(point_count):
		var pos = Vector3(randf() * size.x - size.x / 2, 0.0, randf() * size.y - size.y / 2)
		var transform = Transform().translated(pos)
		transform.basis = transform.basis.rotated(Vector3.UP, 2*PI*randf())
		var size = 0.3 * randf() + 0.6
		transform.basis = transform.basis.scaled(Vector3(size, size, size))
		_multi_mesh.multimesh.set_instance_transform(i, transform)
	
	var material = _multi_mesh.multimesh.mesh.surface_get_material(0)
	material.set_shader_param("height_map", height_map)


func _process(delta):
	_multi_mesh.multimesh.visible_instance_count = int(size.x * size.y * grass_density)
	var displacement = _viewport.get_texture()
	var material = _multi_mesh.multimesh.mesh.surface_get_material(0)
	# I am not sure why the texture must be manually set. It should work when
	# set via shader texture but it does not. Godot Bug?
	material.set_shader_param("displacement_map", displacement)
	#material.set_shader_param("height_zero", heightmap_zero)
