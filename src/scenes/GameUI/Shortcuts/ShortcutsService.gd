class_name ShortcutsService

const _shortcut_file = "user://shortcuts.save"

signal shortcuts_changed

var _shortcuts = {}

func _init():
	load_data()

func load_data() -> void:
	var shortcut_file = File.new()
	if not shortcut_file.file_exists(_shortcut_file):
		return
	shortcut_file.open(_shortcut_file, File.READ)
	var text = ""
	while not shortcut_file.eof_reached():
		var line = shortcut_file.get_line()
		text += line
	shortcut_file.close()
	var shortcut_data = parse_json(text)
	
	if not shortcut_data:
		printerr("Shortcut File corrupted: ", text)
		return
	
	for scd in shortcut_data:
		_shortcuts[scd.slot] = scd


func get_shortcut(slot: String) -> ShortcutData:
	if not _shortcuts.has(slot):
		return null
	var saved_data = _shortcuts[slot]
	var data = ShortcutData.new()
	data.icon = saved_data.icon
	data.type = saved_data.type
	data.slot = saved_data.slot
	data.payload = saved_data.payload
	
	return data


func delete_shortcut(slot: String) -> void:
	if _shortcuts.has(slot):
		_shortcuts.erase(slot)
		emit_signal("shortcuts_changed")
		_persist_locally()
		_persist_online()


func save_shortcut(slot: String, payload: ShortcutData) -> void:
	_shortcuts[slot] = payload
	emit_signal("shortcuts_changed")
	_persist_locally()
	_persist_online()


func _persist_locally() -> void:
	var shortcut_file = File.new()
	var data = []
	for key in _shortcuts.keys():
		var value = _shortcuts[key]
		data.append({
			"icon": value.icon,
			"type": value.type,
			"payload": value.payload,
			"slot": key
		})
	var json_data = to_json(data)
	shortcut_file.open(_shortcut_file, File.WRITE)
	shortcut_file.store_line(json_data)
	shortcut_file.close()


func _persist_online() -> void:
	print_debug("_persist_online() not implemented")
	pass
