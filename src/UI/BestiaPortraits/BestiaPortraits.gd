extends VBoxContainer

const BestiaPortrait = preload("res://UI/BestiaPortraits/BestiaPortrait/BestiaPortrait.tscn")

var _portraits = {}

func _ready():
	GlobalEvents.connect("onPlayerEntityUpdated", self, "_player_entity_updated")
	for c in get_children():
		c.queue_free()


func _player_entity_updated(entity: Entity) -> void:
	# TODO This must be done better. We must sync the owned bestias with the portraits here.
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
