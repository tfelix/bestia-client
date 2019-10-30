extends Control

onready var _search_text = $AttackPanel/BorderMargin/Attacks/Search/Search

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_Close_pressed():
	queue_free()


func _on_ClearButton_pressed():
	_search_text.clear()


func _on_Search_text_changed(new_text):
	pass # Replace with function body.
