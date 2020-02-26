extends Spatial
class_name Item

var Actions = load("res://Actions.gd")

# Funktionen eines Items:
# - Wenn angeklickt und kein default behavior angegeben auswahl des behaviors zeigen
# - Wenn behavior ausgewählt, dann das behavior entscheiden lassen.
# - Klick und Mouse Over muss erkennbar sein.

export(Texture) var item_icon
export(String) var item_name = "undefined"
export(int) var item_weight = 10 # 1 unit is 100gr thus 10 is 1kg

func _ready():
  _orient_item_randomly()

func _orient_item_randomly():
  # When an item is dropped it should orient itself randomly on the world map
  pass

func _on_PickUpCollidor_mouse_entered():
  print_debug("Mouse entered")
  pass # Replace with function body.

func _on_PickUpCollidor_mouse_exited():
  print_debug("Mouse exit")
  pass # Replace with function body.

func _on_PickUpCollidor_clicked(camera, event, click_position, click_normal, shape_idx):
	if !event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		return
