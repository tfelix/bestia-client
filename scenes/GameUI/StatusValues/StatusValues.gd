extends PanelContainer


onready var _click = $CloseClick


func _ready():
	PubSub.subscribe(PST.ENTITY_PLAYER_UPDATED, self)


func free() -> void:
  PubSub.unsubscribe(self)
  .free()

func event_published(event_key, payload) -> void:
	match (event_key):
		PST.ENTITY_PLAYER_UPDATED:
			var data = payload.get_component(StatusComponent.NAME)
			if data != null:
				_update_values(payload)


func _update_values(data: StatusComponent) -> void:
	pass


func _on_Close_pressed() -> void:
	_click.play()
