extends Control
class_name TownName

var colorNeutral = Color(1, 1, 1)
var colorPvpEnabled = Color(1, 0.429688, 0.429688)

export var text = ""
export(bool) var is_pvp = false

onready var label = $BackgroundPanel/CenterContainer/TownName

func _ready():
	label.text = text
	if is_pvp:
		label.set("custom_colors/font_color", colorPvpEnabled)
	else:
		label.set("custom_colors/font_color", colorNeutral)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
