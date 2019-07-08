extends Control
class_name InteractionsUi

var entity: Entity

func add_interaction_ui(ui_node: Node):
	$VBoxContainer.add_child(ui_node)