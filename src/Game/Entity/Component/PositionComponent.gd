extends Component
class_name PositionComponent

const NAME = "PositionComponent"

var _spatial: Spatial

var x: int
var y: int
var z: int

func get_name() -> String:
	return NAME
	

func on_update(entity, component_data) -> void:
	# We might need a mechanism to constantly interact with the entity.
	# e.g. we update the position from the server and the game entity
	# must slowly moved towards this point
	x = component_data.data["x"]
	y = component_data.data["y"]
	z = component_data.data["z"]
	
	_spatial.global_transform.origin = Vector3(x, y, z)


func on_attach(entity) -> void:
	_spatial = entity.get_spatial()


"""
We must keep the position updated from the player.
"""
func _process(delta):
	var origin = _spatial.global_transform.origin
	x = origin.x
	y = origin.y
	z = origin.z
