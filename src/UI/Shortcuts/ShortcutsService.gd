class_name ShortcutsService

const SAVE_FILE = "user://shortcuts.tres"

signal shortcuts_changed

var _shortcuts = {}

func _init():
	load_data()


func load_data() -> void:
	var file := File.new()
	if not file.file_exists(SAVE_FILE):
		print("Shortcut save file %s does not exist" % SAVE_FILE)
		return
	var shortcuts: ShortcutsData = load(SAVE_FILE)
	if shortcuts == null:
		printerr("Shortcut save file %s seems corrupted" % SAVE_FILE)
		var dir := Directory.new()
		dir.remove(SAVE_FILE)
		return
	for sc in shortcuts.shortcuts:
		_shortcuts[sc.slot] = sc


func get_shortcut(slot: String) -> ShortcutData:
	if not _shortcuts.has(slot):
		return null
	return _shortcuts[slot]


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
	var shortcuts := ShortcutsData.new()
	for sc in _shortcuts.values():
		shortcuts.shortcuts.append(sc)
	
	var error: int = ResourceSaver.save(SAVE_FILE, shortcuts)
	if error != OK:
		printerr("There was an issue writing the shortcut file to %s" % SAVE_FILE)


func _persist_online() -> void:
	print_debug("_persist_online() not implemented")
	pass
