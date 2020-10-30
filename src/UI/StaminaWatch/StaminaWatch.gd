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
	GlobalEvents.connect("player_entity_updated", self, "_update")


func _update(player: Player, component: ComponentData) -> void:
	if component.name == "condition":
		var max_stamina = component.max_stamina
		var stamina_perc = float(component.max_stamina) / component.cur_stamina
		_progress.value = stamina_perc * 100
	if component.name == "status":
		var stamina_regen = component.data.stamina_regen
		var stamina_regen_min = stamina_regen * 60.0
		var is_fast = abs(stamina_regen) / component.data.max_stamina > 0.05
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
