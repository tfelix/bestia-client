extends Component
class_name ConditionComponent

const NAME = "ConditionComponent"

export var max_health: int = 1
export var cur_health: int

export var max_mana: int = 1
export var cur_mana: int

export var max_stamina: int = 1
export var cur_stamina: int


func get_health_perc():
	return float(cur_health) / max_health


func get_mana_perc():
	return float(cur_mana) / max_mana


func get_stamina_perc():
	return float(cur_stamina) / max_stamina

func get_name() -> String:
	return NAME
