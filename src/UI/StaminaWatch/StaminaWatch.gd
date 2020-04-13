"""
Displays the current stamina meter of the player. For the indicator they
take into account the speed of the stamina loss or gain. The ticks you
see is the stamina gain per second. 
Small loss or gain: <= -/+ 5% / min
Fast loss or gain: > +/- 5% / min
"""
extends HBoxContainer


export var up_indicator = Color("#6aed5f")
export var down_indicator = Color("#ff4f4f")

onready var _progress = $TextureProgress
onready var _up = $Indicators/UpIndicator
onready var _down = $Indicators/DownIndicator


func _ready():
	GlobalEvents.connect("onPlayerEntityUpdated", self, "_update")


func _update(player) -> void:
	var cond_comp = player.get_component(ConditionComponent.NAME) as ConditionComponent
	if cond_comp == null:
		return
	var max_stamina = cond_comp.max_stamina
	var stamina_perc = float(cond_comp.max_stamina) / cond_comp.cur_stamina
	_progress.value = stamina_perc * 100
	
	var status_comp = player.get_component(StatusComponent.NAME) as StatusComponent
	if status_comp == null:
		return
	var stamina_regen = status_comp.stamina_regen
	var stamina_regen_min = stamina_regen * 60.0
	var is_fast = abs(stamina_regen) / max_stamina > 0.05
	if stamina_regen < 0:
		_up.modulate = Color(1.0,1.0,1.0, 0.0)
		if is_fast:
			_down.modulate = Color(
				down_indicator.r, 
				down_indicator.g, 
				down_indicator.b, 
				1.0
			)
		else:
			_down.modulate = Color(
				down_indicator.r, 
				down_indicator.g, 
				down_indicator.b, 
				0.7
			)
	else:
		_down.modulate = Color(1.0,1.0,1.0, 0.0)
		if is_fast:
			_up.modulate = Color(
				up_indicator.r, 
				up_indicator.g, 
				up_indicator.b, 
				1.0
			)
		else:
			_up.modulate = Color(
				up_indicator.r, 
				up_indicator.g, 
				up_indicator.b, 
				0.7
			)
