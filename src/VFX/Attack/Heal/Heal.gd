extends Attack

onready var _crosses = $Crosses


func _emit_particles() -> void:
	# workaround as its seems setting emission from animation player
	# has some issues and emission setting is kept on all the time
	_crosses.emitting = true
