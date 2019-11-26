extends Control

onready var _row_1 = $Rows/Row1
onready var _row_2 = $Rows/Row2

var _shortcuts

func _ready():
	_shortcuts = _row_1.get_children() + _row_2.get_children()
	_load_data()


func save_shortcut(action_name: String, trigger: Trigger) -> void:
	for sc in _shortcuts:
		if sc.shortcut_action_name == action_name:
			sc.add_trigger(trigger)
			_persist_locally()
			_persist_online()
			return
	print_debug("Shortcut with action ", action_name, " not found")


func _persist_locally() -> void:
	var shortcut_file = File.new()
	shortcut_file.open("user://shortcuts.save", File.WRITE)
	var data = []
	for i in _shortcuts:
		data.append(i.to_json_dict())
	var json_data = to_json(data)
	shortcut_file.store_line(json_data)
	shortcut_file.close()


func _persist_online() -> void:
	print_debug("_persist_online() not implemented")
	pass


func _load_data() -> void:
	var shortcut_file = File.new()
	if not shortcut_file.file_exists("user://shortcuts.save"):
		return
	shortcut_file.open("user://shortcuts.save", File.READ)
	var line = shortcut_file.get_line()
	shortcut_file.close()
	var shortcut_data = parse_json(line)
	
	var slot = 0
	for scd in shortcut_data:
		if scd == null:
			# This is an empty slot
			pass
		elif scd.clazz == "ItemTrigger":
			var trigger = ItemTrigger.new()
			trigger.icon = scd.icon
			trigger.player_item_id = int(scd.player_item_id)
			_shortcuts[slot].add_trigger(trigger)
		elif scd.clazz == "SkillTrigger":
			var trigger = SkillTrigger.new()
			trigger.icon = scd.icon
			trigger.skill_db_name = scd.skill_db_name
			trigger.skill_level = int(scd.skill_level)
			_shortcuts[slot].add_trigger(trigger)
		else:
			print_debug("Unknown Trigger Class: ", scd.clazz)
		slot += 1
	# TODO Also request the data from the server