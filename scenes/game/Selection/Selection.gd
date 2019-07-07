extends Spatial

var PST = load("res://PubSubTopics.gd")

export(NodePath) var interactions_path
export(NodePath) var selection_mesh

var is_selected: bool = false
var interactions: Interactions

# Called when the node enters the scene tree for the first time.
func _ready():
	interactions = get_node(interactions_path)
	var node = get_node(selection_mesh)
	var aabb = node.get_aabb()
	var longest_axis_size = aabb.get_longest_axis_size()
	$RingHighlight.transform.scaled(Vector3(longest_axis_size, longest_axis_size, 1))
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
	interactions.abort_interaction()


func event_published(event_key, payload):
  if event_key == PST.ENTITY_SELECTED && payload != self:
    unselected()