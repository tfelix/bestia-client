extends Area

export var town_name: String = ""

func _on_NotificationArea_body_entered(body):
	var town_name_ui = load("res://scenes/GameUI/TownName/TownName.tscn")
	var town_name_node = town_name_ui.instance()
	town_name_node.set_town_name(town_name, false)
	get_tree().root.add_child(town_name_node)
