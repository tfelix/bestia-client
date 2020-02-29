extends Particles

export var rows = 4 setget set_rows, get_rows
export var spacing = 1.0 setget set_spacing, get_spacing

# This is for testing only as we must find a way to process more
# grass displacement. Probably need a texture for this which we must
# pre calculate
export var playerNodePath: NodePath

var playerNode: Spatial

func update_aabb():
	var size = rows * spacing
	visibility_aabb = AABB(Vector3(-0.5 * size, 0.0, -0.5 * size), Vector3(size, 20.0, size))

func set_rows(new_rows):
	rows = new_rows
	amount = rows * rows
	update_aabb()
	if process_material:
		process_material.set_shader_param("rows", new_rows)

func get_rows():
	return rows

func set_spacing(new_spacing):
	spacing = new_spacing
	update_aabb()
	if process_material:
		process_material.set_shader_param("spacing", spacing)

func get_spacing():
	return spacing

# Called when the node enters the scene tree for the first time.
func _ready():
	set_rows(rows)
