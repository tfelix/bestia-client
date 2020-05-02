extends Particles


export var displacement_scale: float = 3.0

func _read() -> void:
	process_material.set("scale", displacement_scale)
