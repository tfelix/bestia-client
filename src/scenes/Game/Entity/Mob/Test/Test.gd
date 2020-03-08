extends Spatial


export var entity_id = 0

onready var entity = $Entity

# Called when the node enters the scene tree for the first time.
func _ready():
	entity.id = entity_id

