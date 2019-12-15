extends Spatial

var _entity_clicked_handler: SkillCastEntityClickedHandler

func _ready() -> void:
	PubSub.subscribe(PST.ENTITY_CLICKED, self)
	PubSub.subscribe(PST.ENTITY_CLICKED_HANDLER, self)


func free() -> void:
  PubSub.unsubscribe(self)
  .free()


func event_published(event_key, payload) -> void:
	match (event_key):
		PST.ENTITY_CLICKED:
			_handle_entity_clicked(payload)
		PST.ENTITY_CLICKED_HANDLER:
			_entity_clicked_handler = payload
			_entity_clicked_handler.handler_installed()


func _handle_entity_clicked(entity: Entity) -> void:
	if _entity_clicked_handler != null:
		_entity_clicked_handler.on_entity_clicked(entity)
		# TODO Probably needs better conditional handling
		_entity_clicked_handler.handler_removed()


func _process(delta):
	PubSub.process()
