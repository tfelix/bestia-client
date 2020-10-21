extends BoneAttachment
class_name Hair

onready var _mesh = $HairMesh


func set_haircolor(color: Color) -> void:
	var mat = _mesh.mesh.surface_get_material(0)
	mat.albedo_color = color
