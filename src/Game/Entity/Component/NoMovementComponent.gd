extends Component
class_name NoMovementComponent

const NAME = "NoMovementComponent"

# Can be filled with a string to clearify where the component came
# from in order to properly remove it. Contains string names.
var origins = []

func _init():
	local_only = true
	

func get_name() -> String:
	return NAME
