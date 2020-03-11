extends Component
class_name StatusComponent

const NAME = "StatusComponent"

var physicalDefense: int
var magicDefense: int
var strength : int
var vitality : int
var intelligence: int
var agility : int
var willpower : int
var dexterity: int
var hpRegenRate: float
var manaRegenRate: float
var staminaRegenRate: float
var criticalHitrate: float
var dodge: float
var casttimeMod: float
var cooldownMod: float
var spellDurationMod: float
var hitrate: float
var attackSpeed: float
var walkspeed: float
# Element element = 21;

func get_name() -> String:
	return NAME
