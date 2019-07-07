extends Control

const ItemModel = preload("res://scenes/ui/inventory/ItemModel.gd")

func show_message(item: ItemModel) -> void:
	# TODO Setup the icon
	var text = str(item.amount, "x ", item.name)
	($Margin/HBox/Icon as TextureRect).texture = item.icon
	($Margin/HBox/Label as Label).text = text

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	print_debug("_on_AnimationPlayer_animation_finished")
	if anim_name == "fade_in":
		$Timer.start()
	if anim_name == "fade_out":
		queue_free()

func _on_Timer_timeout() -> void:
	$AnimationPlayer.play("fade_out")
