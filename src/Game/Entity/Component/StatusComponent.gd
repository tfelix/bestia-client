extends Component
class_name StatusComponent

const NAME = "StatusComponent"

enum Element {
	NORMAL
}

export var physical_defense: int = 0
export var magic_defense: int = 0

export var strength : int = 1
export var vitality : int = 1
export var intelligence: int = 1
export var agility : int = 1
export var willpower : int = 1
export var dexterity: int = 1

export var hp_regen: float
export var mana_regen: float
export var stamina_regen: float
export var critical_hitrate: float
export var dodge: float
export var casttime_mod: float
export var cooldown_mod: float
export var spell_duration_mod: float
export var hitrate: float
export var attack_speed: float
export var walkspeed: float

export(Element) var element = Element.NORMAL
export var available_status_ups: int = 0

func get_name() -> String:
	return NAME
