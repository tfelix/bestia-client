extends Spatial
class_name SimpleBar

export var size: Vector2 = Vector2(1.4, 0.2)
export var bar_color: Color = Color(0.92549, 0, 0)
export var background_color: Color = Color(0.25098, 0.25098, 0.25098)
export(float, 0, 1) var percentage = 1

onready var bar_material = $BarMesh.get_surface_material(0)

func _process(delta):
	bar_material.set_shader_param("barColor", bar_color)
	bar_material.set_shader_param("backgroundColor", background_color)
	bar_material.set_shader_param("barSize", size)
	bar_material.set_shader_param("percentage", percentage)