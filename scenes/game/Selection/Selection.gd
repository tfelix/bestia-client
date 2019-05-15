extends Spatial

export(NodePath) var interactions
export(NodePath) var selection_mesh

var is_selected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var node = get_node(selection_mesh)
	var aabb = node.get_aabb()
	var longest_axis_size = aabb.get_longest_axis_size()
	$RingHighlight.transform.scaled(Vector3(longest_axis_size, longest_axis_size, 1))
	# Export the publish keys at least to a constant
	PubSub.subscribe("item_selected", self)

func selected():
	print_debug("selected")
	visible = true
	is_selected = true
	PubSub.publish("item_selected", self)

func unselected():
	print_debug("unselected")
	visible = false
	is_selected = false

func event_published(event_key, payload):
	if event_key == "item_selected" && payload != self:
		unselected()