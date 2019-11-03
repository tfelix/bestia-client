extends Entity
class_name Mob

var StatusComponent = load("res://scenes/Game/Entity/Component/StatusComponent/StatusComponent.tscn")

func _on_Collidor_input_event(camera, event, click_position, click_normal, shape_idx):
	if event.is_action_pressed(Actions.ACTION_LEFT_CLICK):
		print_debug("Send msg to server")
		_make_player_dmg()


func _make_player_dmg():
	var sc = StatusComponent.instance()
	sc.max_health = 123
	sc.cur_health = int(rand_range(20, 120))
	sc.max_mana = 140
	sc.cur_mana = int(rand_range(10, 130))
	Global.player.update_component(sc)