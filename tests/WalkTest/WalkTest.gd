extends Spatial


func _unhandled_key_input(event):
	if Input.is_key_pressed(KEY_S):
		_start_construction()


func _start_construction() -> void:
	var item_path = "res://scenes/Game/Entity/Struct/SignSmall/SignSmall.tscn"
	var item_scene = load(item_path)
	var item_instance = item_scene.instance()
	get_tree().root.add_child(item_instance)
	item_instance.start_construct()
