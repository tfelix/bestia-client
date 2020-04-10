extends MarginContainer

signal close_clicked

export(String) var title_text

onready var title = $TitleRow/Title
onready var click = $ClickPlayer

func _ready() -> void:
	title.text = title_text


func _on_Close_pressed():
	click.play()
	emit_signal("close_clicked")
