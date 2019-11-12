extends Area
class_name InteractionRange

func is_player_in_range() -> bool:
	var player = Global.entities.get_player()
	if player == null:
		return false
	return overlaps_body(player)
