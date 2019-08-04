extends Spatial

var Actions = load("res://Actions.gd")
var DialogText = load("res://scenes/ui/dialog_text/ScreenBottomText.tscn")

onready var player = Global.player
export var text = ""

func _ready():
	pass # Replace with function body.

func _on_col_mouse_entered():
	print_debug("on mouse over")

func _on_col_mouse_exited():
	print_debug("on mouse exit")

func _on_col_input_event(camera, event, click_position, click_normal, shape_idx):
	if !event.is_action(Actions.ACTION_LEFT_CLICK):
		return
	get_tree().set_input_as_handled()
	print_debug("sign was clicked")
	var is_player_in_range = $UseRange.overlaps_body(player)
	
	if is_player_in_range:
		var dialog = DialogText.instance()
		dialog.set_text(text)
		get_tree().root.add_child(dialog)
