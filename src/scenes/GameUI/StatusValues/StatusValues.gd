extends PanelContainer

onready var _click = $CloseClick


func _ready():
	GlobalEvents.connect("onPlayerEntityUpdated", self, "_update_values")


func _update_values(player_entity: StatusComponent) -> void:
	var data = player_entity.get_component(StatusComponent.NAME)
	if data == null:
		return
	pass


func _on_Close_pressed() -> void:
	_click.play()
