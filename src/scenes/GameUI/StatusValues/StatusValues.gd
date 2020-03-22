extends PanelContainer

onready var _click = $CloseClick

onready var _strength = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrValue
onready var _strength_mod = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrMod
onready var _strength_cost = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrCost
onready var _strength_up = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrUp

onready var _vitality = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitValue
onready var _vitality_mod = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitMod
onready var _vitality_cost = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitCost
onready var _vitality_up = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitUp

var _strength_cost_value = 0
var _vitality_cost_value = 0

export var available_points = 0
export(Color) var reduced_status_color = Color(0.796875, 0.174316, 0.174316)


func _ready():
	GlobalEvents.connect("onPlayerEntityUpdated", self, "_update_values")


func _update_values(player: Entity) -> void:
	var data = player.get_component(StatusComponent.NAME) as StatusComponent
	if data == null:
		return


func _check_up_buttons_enabled() -> void:
	_strength_up.disabled = _strength_cost_value > available_points
	_vitality_up.disabled = _vitality_cost_value > available_points


func hide() -> void:
	_click.play()
	.hide()


func show() -> void:
	_click.play()
	.show()


func _on_Close_pressed() -> void:
	hide()


func _on_StrUp_pressed():
	pass # Replace with function body.


func _on_VitUp_pressed():
	pass # Replace with function body.


func _unhandled_key_input(event):
	if not event.is_action_pressed("ui_status_values"):
		return
	
	if visible:
		hide()
	else:
		show()


func _on_Save_pressed():
	pass # Replace with function body.


func _on_Cancel_pressed():
	hide()


func _on_StatusValues_mouse_entered():
	GlobalEvents.emit_signal("onUiEntered")


func _on_StatusValues_mouse_exited():
	GlobalEvents.emit_signal("onUiExited")
