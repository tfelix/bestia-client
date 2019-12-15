extends VBoxContainer

const BestiaPortrait = preload("res://scenes/GameUI/BestiaPortraits/BestiaPortrait/BestiaPortrait.tscn")

var _portraits = {}

func _ready():
	PubSub.subscribe(PST.ENTITY_PLAYER_UPDATED, self)
	for c in get_children():
		c.queue_free()


func free():
	PubSub.unsubscribe(self)
	.free()


func event_published(event_key, payload) -> void:
	match (event_key):
		PST.ENTITY_PLAYER_UPDATED:
			_player_entity_updated(payload)


func _player_entity_updated(entity: Entity) -> void:
	if !_portraits.has(entity.id):
		var new_portrait = BestiaPortrait.instance()
		_portraits[entity.id] = new_portrait
		add_child(new_portrait)
	var portrait = _portraits[entity.id]
	var condition_comp = entity.get_component(ConditionComponent.NAME) as ConditionComponent
	var player_comp = entity.get_component(PlayerComponent.NAME) as PlayerComponent
	if player_comp == null || condition_comp == null:
		return
	var data = BestiaPortraitData.new()
	data.name = "Test"
	data.hp_percentage = condition_comp.get_health_perc();
	data.mana_percentage = condition_comp.get_mana_perc();
	data.player_bestia_id = player_comp.player_bestia_id
	portrait.set_portrait_data(data)