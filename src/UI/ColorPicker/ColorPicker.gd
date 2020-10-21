extends GridContainer

signal color_selected 

# Called when the node enters the scene tree for the first time.
func _ready():
	for n in get_children():
		n.connect("selected", self, "_on_Color_selected")


func _on_Color_selected(selected_color_node):
	for n in get_children():
		if n != selected_color_node:
			n.unselect()
		else:
			emit_signal("color_selected", n.color)

