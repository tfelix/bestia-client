class_name DamageMessage

enum DamageType {
	DAMAGE,
	CRIT_DAMAGE,
	HEAL,
	MISS
}

var type = DamageType.DAMAGE
var target_entity: int
var total_damage: int
# Damage can consist out of multiple hits.
var sub_damages: Array
