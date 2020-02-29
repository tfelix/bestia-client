extends Component
class_name ConditionComponent

const NAME = "ConditionComponent"

var max_health: int
var cur_health: int

var max_mana: int
var cur_mana: int

var max_stamina: int
var cur_stamina: int


func get_health_perc():
	return float(cur_health) / max_health


func get_mana_perc():
	return float(cur_mana) / max_mana


func get_stamina_perc():
	return float(cur_stamina) / max_stamina

func get_name() -> String:
	return NAME