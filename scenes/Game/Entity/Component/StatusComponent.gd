extends Component
class_name StatusComponent

const NAME = "StatusComponent"

var max_health: int
var cur_health: int

var max_mana: int
var cur_mana: int

func get_name() -> String:
	return NAME