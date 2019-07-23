extends Control

onready var _row_1 = $Rows/Row1

func _ready():
	# This is for testing. We Setup the first shortcut to be fireball
	# This must be done e.g. via the Inventory or the Skill Menu
	var st = SkillTrigger.new()
	st.icon = load("res://scenes/GameUI/shortcuts/fireball.png")
	st.skill_db_name = "fireball"
	st.skill_level = 1
	var sc1 = _row_1.get_child(0)
	sc1.add_trigger(st)
