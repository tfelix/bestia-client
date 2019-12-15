class_name SetTriggerShortcutCallback

var trigger: Trigger
var shortcuts


func triggered(shortcut_action: String):
	shortcuts.save_shortcut(shortcut_action, trigger)