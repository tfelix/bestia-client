extends Spatial

# TODO Make a own category for structures with all the needed logic

export var text = ""
export(ItemModel.ItemType) var type = ItemModel.ItemType.ETC

var _is_constructing = false

onready var _mesh = $SignMesh
onready var _building_mesh = $SignMeshBuilding
onready var _collidor = $Collidor
onready var _user_input = $SignContentInput


func _physics_process(delta):
	if !_is_constructing:
		return
	var cam = get_tree().get_root().get_camera()
	var mouse_pos = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mouse_pos)
	var ray_length = 300
	var to = from + cam.project_ray_normal(mouse_pos) * ray_length
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], 32)
	
	if result.size() == 0:
		_building_mesh.visible = false
	else:
		_building_mesh.visible = true
		self.global_transform.origin = result.position


func use_item() -> void:
	if type == ItemModel.ItemType.CONSUMEABLE:
		# If its a consumable item, just consume it and send message to the server
		return
	if type == ItemModel.ItemType.STRUCTURE:
		start_construct()
	pass


"""
If its a structure item start the construction mode this means:
close inventory if opened, 
go into ctor mouse pointer, 
dont move the player
"""
func start_construct() -> void:
	GlobalEvents.emit_signal("onStructureConstructionStarted", self)
	_is_constructing = true
	_mesh.hide()
	_building_mesh.show()


func stop_construct() -> void:
	GlobalEvents.emit_signal("onStructureConstructionEnded", self)
	queue_free()


func _on_col_mouse_entered():
	print_debug("on mouse over")


func _on_col_mouse_exited():
	print_debug("on mouse exit")


func _on_col_input_event(camera, event, click_position, click_normal, shape_idx):
	if !event.is_action(Actions.ACTION_LEFT_CLICK):
		return
	get_tree().set_input_as_handled()
	print_debug("sign was clicked")
	# var is_player_in_range = $UseRange.overlaps_body(player)
	
	# if is_player_in_range:
		# var dialog = DialogText.instance()
		# dialog.set_text(text)
		# get_tree().root.add_child(dialog)


func _handle_default_input() -> void:
	if _is_constructing:
		pass
	._handle_default_input()


func _handle_secondary_input() -> void:
	if _is_constructing:
		pass
	._handle_secondary_input()


func _unhandled_key_input(event):
	if _is_constructing && event.is_action_pressed("ui_cancel"):
		stop_construct()


func _unhandled_input(event):
	if event.is_action("left_click") && _is_constructing:
		if _pre_construct() == true:
			stop_construct()


func _pre_construct() -> bool:
	_user_input.show()
	_is_constructing = false
	return false


func _on_SignContentInput_text_entered(arg):
	print_debug("Send to server: Input, Position, Text: ", arg)
	stop_construct()
