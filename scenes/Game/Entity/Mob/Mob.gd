extends Entity
class_name Mob

var Damage3D = load("res://scenes/Game/Damage/Damage3D.tscn")
var Damage = load("res://scenes/Game/Damage/Damage.gd")
var StatusComponent = load("res://scenes/Game/Entity/Component/StatusComponent/StatusComponent.tscn")

func _on_Collidor_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		var dmg = Damage.Damage.new(123, Damage.DamageType.DAMAGE) 
		var dmg3d = Damage3D.instance()
		var source = Global.player
		dmg3d.init(dmg, source)
		add_child(dmg3d)
		$AudioPunch.play()
		_make_player_dmg()

func _make_player_dmg():
	var sc = StatusComponent.instance()
	sc.max_health = 123
	sc.cur_health = int(rand_range(20, 120))
	sc.max_mana = 140
	sc.cur_mana = int(rand_range(10, 130))
	Global.player.update_component(sc)