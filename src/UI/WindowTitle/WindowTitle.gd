extends PanelContainer

signal close_clicked
signal drag_started
signal drag_ended

export(String) var title_text
export(Texture) var icon

onready var _title = $TitleRow/Title
onready var _click = $ClickPlayer
onready var _icon = $TitleRow/IconMargin/Icon

func _ready() -> void:
	_title.text = title_text
	_icon.texture = icon


func _on_Close_pressed():
	_click.play()
	emit_signal("close_clicked")
