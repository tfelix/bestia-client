extends Control

signal on_inventory_pressed
signal on_attacks_pressed
signal status_values_pressed
signal equip_pressed

onready var _character_name = $MainCols/CharInfoMargin/Rows/CharacterInfo
onready var _health_bar = $MainCols/CharInfoMargin/Rows/Main/Bars/HpBar
onready var _mana_bar = $MainCols/CharInfoMargin/Rows/Main/Bars/ManaBar
onready var _health_label = $MainCols/CharInfoMargin/Rows/Main/Bars/HealthLabel
onready var _mana_label = $MainCols/CharInfoMargin/Rows/Main/Bars/ManaLabel


func _ready():
	GlobalEvents.connect("onPlayerEntityUpdated", self, "_on_player_changed")


func _on_player_changed(player: Entity):
	var info = player.get_component(PlayerComponent.NAME) as PlayerComponent
	if info == null:
		printerr("No PlayerInfo component on player node")
		return
	
	_character_name.text = info.player_name
	
	var condition = player.get_component(ConditionComponent.NAME) as ConditionComponent
	if condition == null:
		printerr("No ConditionComponent on player node")
		return
	
	_on_player_component_changed(condition)


func _on_player_component_changed(component: ConditionComponent):
	_health_bar.set_value(component.get_health_perc())
	_mana_bar.set_value(component.get_mana_perc())
	var mana_txt = "Mana: %d / %d" % [component.cur_mana, component.max_mana] 
	var hp_txt = "HP: " + str(component.cur_health) + " / " + str(component.max_health)
	_health_label.text = hp_txt
	_mana_label.text = mana_txt


func _on_Inventory_pressed():
	emit_signal("on_inventory_pressed")


func _on_Attacks_pressed():
	emit_signal("on_attacks_pressed")


func _on_Status_pressed():
	emit_signal("status_values_pressed")


func _on_Equip_pressed():
	emit_signal("equip_pressed")
