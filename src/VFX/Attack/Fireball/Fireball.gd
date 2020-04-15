extends Attack

onready var _smoke = $Smoke


func _damage_triggered() -> void:
	_smoke.emitting = true

