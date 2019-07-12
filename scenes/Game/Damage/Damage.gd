enum DamageType {
	DAMAGE,
	CRIT_DAMAGE,
	HEAL,
	MISS
}

class Damage:
	var amount: int
	var type = DamageType.DAMAGE
	
	func _init(_amount: int, _type: int):
		amount = _amount
		type = _type