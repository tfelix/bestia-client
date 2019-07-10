extends Area
class_name InteractionRange

func is_player_in_range() -> bool:
	var player = Global.player
	return overlaps_body(player)
