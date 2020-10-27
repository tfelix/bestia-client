extends Spatial
class_name Item

onready var _entity = $Entity

func _ready():
  _orient_item_randomly()

func _orient_item_randomly():
  # When an item is dropped it should orient itself randomly on the world map
  pass


func handle_message(msg):
	_entity.handle_message(msg)
