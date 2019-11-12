extends Spatial

var PST = load("res://PubSubTopics.gd")

export(NodePath) var selection_mesh_path = ""

var is_selected: bool = false
onready var interactions: Interactions = get_parent().get_node("Interactions")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Export the publish keys at least to a constant
	PubSub.subscribe(PST.ENTITY_SELECTED, self)

func free():
	PubSub.unsubscribe(self)
	.free()

func selected():
	visible = true
	is_selected = true
	PubSub.publish(PST.ENTITY_SELECTED, self)


func unselected():
	visible = false
	is_selected = false
	if interactions != null:
		interactions.abort_interaction()


func event_published(event_key, payload):
  if event_key == PST.ENTITY_SELECTED && payload != self:
    unselected()