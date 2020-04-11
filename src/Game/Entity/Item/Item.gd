extends Spatial
class_name Item

# Funktionen eines Items:
# - Wenn angeklickt und kein default behavior angegeben auswahl des behaviors zeigen
# - Wenn behavior ausgewählt, dann das behavior entscheiden lassen.
# - Klick und Mouse Over muss erkennbar sein.

onready var _entity = $Entity

func _ready():
  _orient_item_randomly()

func handle_message(msg):
	_entity.handle_message(msg)

func _orient_item_randomly():
  # When an item is dropped it should orient itself randomly on the world map
  pass
