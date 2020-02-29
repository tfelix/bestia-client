extends Spatial

export var nearGrassRange: float = 3.0
export var mediumGrassRange: float = 10.0

onready var _nearGrass = $NearGrass
onready var _mediumGrass = $MediumGrass
onready var _fakeCam = $FakeCam

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
	var cameraPos = _fakeCam.global_transform.origin # Vector3(0.0, 0.0, 0.0)
	
	if _nearGrass.process_material:
		_nearGrass.process_material.set_shader_param("cameraPosition", cameraPos)
	
	if _mediumGrass.process_material:
		_mediumGrass.process_material.set_shader_param("cameraPosition", cameraPos)
	# TODO Position the systems
	# pos.y = 0.0
	# global_transform.origin = pos