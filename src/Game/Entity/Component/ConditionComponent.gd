extends Component
class_name ConditionComponent

const NAME = "ConditionComponent"

export var max_health: int = 1
export var cur_health: int = 0

export var max_mana: int = 1
export var cur_mana: int = 0

export var max_stamina: int = 1
export var cur_stamina: int = 0


func is_dead() -> bool:
	return cur_health <= 0


func get_health_perc() -> float:
	return float(cur_health) / max_health


func get_mana_perc() -> float:
	return float(cur_mana) / max_mana


func get_stamina_perc() -> float:
	return float(cur_stamina) / max_stamina

func get_name() -> String:
	return NAME

func on_update(entity, component_data: ComponentData) -> void:
	# max_health = component_data.data["max_health"]
	cur_health = component_data.data["cur_health"]
