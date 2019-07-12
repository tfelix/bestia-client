extends Entity
class_name Mob

var Damage3D = load("res://scenes/Game/Damage/Damage3D.tscn")
var Damage = load("res://scenes/Game/Damage/Damage.gd")

func _on_Collidor_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		var dmg = Damage.Damage.new(123, Damage.DamageType.DAMAGE) 
		var dmg3d = Damage3D.instance()
		var source = Global.player
		dmg3d.init(dmg, source)
		add_child(dmg3d)
		$AudioPunch.play()
