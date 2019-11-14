extends Control

onready var _character_name = $Rows/InfoMargin/CharacterInfo
onready var _health_bar = $Rows/Main/Bars/HealthBar
onready var _mana_bar = $Rows/Main/Bars/ManaBar
onready var _health_label = $Rows/Main/Bars/HealthLabel
onready var _mana_label = $Rows/Main/Bars/ManaLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	# Global.connect("player_changed", self, "_on_player_changed")
	pass

func update_player(player: Player):
	var info = player.get_component(PlayerInfoComponent.NAME) as PlayerInfoComponent
	if info == null:
		printerr("No PlayerInfo component on player node")
		return
	_character_name.text = info.player_name
	
	var status = player.get_component(StatusComponent.NAME) as StatusComponent
	if status == null:
		printerr("No Status component on player node")
	_on_player_component_changed(status)
	player.connect("component_changed", self, "_on_player_component_changed")


func _on_player_component_changed(component):
	if !(component is StatusComponent):
		return
	_health_bar.update_values(component.cur_health, component.max_health)
	_mana_bar.update_values(component.cur_mana, component.max_mana)
	var mana_txt = "Mana: %d / %d" % [component.cur_mana, component.max_mana] 
	var hp_txt = "HP: " + str(component.cur_health) + " / " + str(component.max_health)
	_health_label.text = hp_txt
	_mana_label.text = mana_txt

