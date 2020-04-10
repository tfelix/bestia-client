extends VBoxContainer

var _camera: Camera

onready var _mana_bar = $ManaBar
onready var _health_bar = $HpBar

func _ready():
	_camera = get_tree().get_root().get_camera()
	GlobalEvents.connect("onPlayerEntityUpdated", self, "_on_player_changed")


func _process(delta):
	var d_pos = Vector2(-self.rect_size.x / 2, 0)
	var parent_pos = (get_parent() as Spatial).transform.origin
	# Correct the y offset
	parent_pos.y -= 0.7
	var pos = _camera.unproject_position(parent_pos)
	self.set_position(pos + d_pos)


func _on_player_changed(player: Entity):
	var condition = player.get_component(ConditionComponent.NAME) as ConditionComponent
	if condition == null:
		printerr("No ConditionComponent on player node")
		return
	
	_health_bar.set_value(condition.get_health_perc())
	_mana_bar.set_value(condition.get_mana_perc())
