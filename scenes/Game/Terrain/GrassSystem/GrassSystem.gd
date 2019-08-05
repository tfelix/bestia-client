extends Spatial

export var nearGrassRange: float = 3.0
export var mediumGrassRange: float = 10.0

onready var _nearGrass = $NearGrass
onready var _mediumGrass = $MediumGrass

# Other systems can query the grass height at this position.
# Usually needed to place something above the grass.
func getGrassHeight(globalPos: Vector2) -> float:
	return 1.0

func _process(delta):
	# Center our particles on our cameras position
	# Also feed camera position into shader material.
	var viewport = get_viewport()
	var camera = viewport.get_camera()
	# var cameraPos = camera.global_transform.origin
	var cameraPos = Vector3(0.0, 0.0, 0.0)
	
	if _nearGrass.process_material:
		_nearGrass.process_material.set_shader_param("cameraPosition", cameraPos)
		# _nearGrass.process_material.set_shader_param("minRenderDistance", 5.0)
		# _nearGrass.process_material.set_shader_param("maxRenderDistance ", 10.0)
	
	#if _mediumGrass.process_material:
	#	pass
		#_mediumGrass.process_material.set_shader_param("cameraPosition", cameraPos)
		#_mediumGrass.process_material.set_shader_param("minRenderDistance ", nearGrassRange)
		#_mediumGrass.process_material.set_shader_param("maxRenderDistance ", mediumGrassRange)
	# TODO Position the systems
	# pos.y = 0.0
	# global_transform.origin = pos