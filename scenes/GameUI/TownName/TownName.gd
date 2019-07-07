extends Control

var colorNeutral = Color(1, 1, 1)
var colorPvpEnabled = Color(1, 0.429688, 0.429688)

func set_town_name(name: String, is_pvp: bool):
	$CenterContainer/Panel/Label.text = name
	if is_pvp:
		$CenterContainer/Panel/Label.set("custom_colors/font_color", colorPvpEnabled)
	else:
		$CenterContainer/Panel/Label.set("custom_colors/font_color", colorNeutral)


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
