extends Spatial

onready var _viewport = $Viewport as Viewport
onready var _decal = $Decal

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var img = _viewport.get_texture().get_data()
	var tex = ImageTexture.new()
	tex.create_from_image(img)
	_decal.set_decal(tex)
