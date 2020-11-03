extends Control
class_name TownName

var colorNeutral = Color(1, 1, 1)
var colorPvpEnabled = Color(1, 0.429688, 0.429688)

export(String) var text = ""
export(bool) var is_pvp = false

onready var label = $TextureRect/TownName

func _ready():
	set_text(text)
	#if is_pvp:
		#label.set("custom_colors/font_color", colorPvpEnabled)
	#else:
		#label.set("custom_colors/font_color", colorNeutral)


func set_text(value):
	label.text = value


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
