extends PanelContainer

onready var _click = $CloseClick
onready var strength = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrValue
onready var strength_mod = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrMod
onready var strength_cost = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrCost
onready var strength_up = $MainContainer/Body/MarginContainer/StatusValues/Strength/StrUp

onready var vitality = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitValue
onready var vitality_mod = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitMod
onready var vitality_cost = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitCost
onready var vitality_up = $MainContainer/Body/MarginContainer/StatusValues/Vitality/VitUp

export var available_points = 0
export(Color) var reduce_status_color = Color(0.796875, 0.174316, 0.174316)


func _ready():
	GlobalEvents.connect("onPlayerEntityUpdated", self, "_update_values")


func _update_values(player: Entity) -> void:
	var data = player.get_component(StatusComponent.NAME)
	if data == null:
		return


func _on_Close_pressed() -> void:
	_click.play()
	hide()


func _check_up_buttons_enabled() -> void:
	if available_points > 0:
		# Enable all buttons
		pass
	else:
		# Disable all buttons
		strength_up.disabled = true
		vitality_up.disabled = true
