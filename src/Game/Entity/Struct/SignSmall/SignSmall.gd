extends Struct

const TownName = preload("res://UI/TownName/TownName.tscn")

var _is_constructing = false


onready var _mesh = $SignMesh
onready var _building_mesh = $SignMeshBuilding
onready var _collidor = $Collidor
onready var _user_input = $SpatialFollower/SignContentInput
onready var _entity = $Entity
onready var _sign_radius = $SignageDetection/CollisionShape

"""
Prevents display of the signange if a player re-enters
within this time delay.
"""
export(int) var display_cooldown_s = 60
export var text = ""
export var radius = 50

var _last_detection = 0


func _ready():
	_sign_radius.shape.radius = radius


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
		var rx = round(result.position.x)
		var rz = round(result.position.z)
		self.global_transform.origin = Vector3(rx, result.position.y, rz)


func use_item() -> void:
	start_construct()


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


func _unhandled_key_input(event):
	if _is_constructing && event.is_action_pressed("ui_cancel"):
		stop_construct()


func _unhandled_input(event):
	if event.is_action("left_click") && _is_constructing:
		if _pre_construct() == true:
			stop_construct()


func _pre_construct() -> bool:
	_user_input.visible = true
	_is_constructing = false
	GlobalEvents.emit_signal("onStructurePreConstructionStarted", self)
	return false


func _on_SignContentInput_text_entered(arg):
	print_debug("Send to server: Input, Position, Text: ", arg)
	stop_construct()


func _on_SignageDetection_body_entered(body):
	var delta = OS.get_ticks_msec() - _last_detection
	if _last_detection != 0 && delta / 1000 < display_cooldown_s:
		return
	_last_detection = OS.get_ticks_msec()
	
	var town_name = TownName.instance()
	town_name.text = text
	town_name.is_pvp = false
	add_child(town_name)
	


"""
We must update the radius of the sign.
"""
func _on_Entity_component_updated(component):
	if component is DataComponent:
		radius = int(component.data["radius"])
		_sign_radius.shape.radius = radius
	
