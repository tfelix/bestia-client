extends Spatial

onready var _grass = $Grass
onready var _depthmap = $DepthMap


func _process(delta):
	#_grass.height_map = _depthmap.depth_map
	_grass.heightmap_zero = _depthmap.current_ground_distance
