extends Component
class_name PositionComponent

const NAME = "PositionComponent"

var x: int
var y: int
var z: int

func get_name() -> String:
	return NAME


func on_attach(entity) -> void:
	# We might need a mechanism to constantly interact with the entity.
	# e.g. we update the position from the server and the game entity
	# must slowly moved towards this point
	entity.get_spatial().global_transform.origin = Vector3(x, y, z)
