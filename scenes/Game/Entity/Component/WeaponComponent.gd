extends Component
class_name WeaponComponent


const NAME = "WeaponComponent"

enum WeaponType {
	MELEE,
	RANGED
}

export(float) var attack_delay: float = 1.0
export(float) var attack_range: float = 10
export(WeaponType) var weapon_type = WeaponType.MELEE
export(String) var projectile
export(float) var projectile_speed: float = 5


func get_name() -> String:
	return NAME
