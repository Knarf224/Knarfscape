extends CanvasLayer

@onready var skill_list = $Background/SkillList

var _skill_widgets: Dictionary = {}

func _ready():
	await get_tree().process_frame
	if skill_list == null:
		push_error("SkillList node not found!")
		return
	_build_skill_list()
	GameManager.skills.skill_leveled_up.connect(_on_level_up)
	GameManager.skills.xp_gained.connect(_on_xp_gained)

func _build_skill_list():
	for child in skill_list.get_children():
		child.queue_free()
	_skill_widgets.clear()

	for skill_name in GameManager.skills.get_skill_list():
		var container = VBoxContainer.new()
		container.custom_minimum_size = Vector2(170, 0)

		# Skill label — centered
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 11)
		label.text = _format_skill_text(skill_name)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		container.add_child(label)

		# Progress bar
		var bar = ProgressBar.new()
		bar.min_value = 0.0
		bar.max_value = 100.0
		bar.value = _get_xp_percentage(skill_name)
		bar.custom_minimum_size = Vector2(170, 12)
		bar.show_percentage = true
		container.add_child(bar)

		# Spacer
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 3)
		container.add_child(spacer)

		skill_list.add_child(container)

		_skill_widgets[skill_name] = {
			"label": label,
			"bar": bar
		}

func _format_skill_text(skill_name: String) -> String:
	var level = GameManager.skills.get_level(skill_name)
	var xp_to_next = GameManager.skills.get_xp_to_next_level(skill_name)
	if level >= 50:
		return skill_name.capitalize() + ": " + str(level) + " (MAX)"
	return skill_name.capitalize() + ": " + str(level) + " (" + str(int(xp_to_next)) + "xp till level)"

func _get_xp_percentage(skill_name: String) -> float:
	var level = GameManager.skills.get_level(skill_name)
	if level >= 50:
		return 100.0
	var xp_table = GameManager.skills.XP_TABLE
	var xp_current = GameManager.skills.get_xp(skill_name)
	var xp_start_of_level = xp_table[level - 1]
	var xp_end_of_level = xp_table[level]
	var xp_into_level = xp_current - xp_start_of_level
	var xp_needed_for_level = xp_end_of_level - xp_start_of_level
	if xp_needed_for_level <= 0:
		return 0.0
	return (xp_into_level / xp_needed_for_level) * 100.0

func _on_level_up(skill_name: String, _new_level: int):
	_update_skill_widget(skill_name)

func _on_xp_gained(skill_name: String, _amount: float):
	_update_skill_widget(skill_name)

func _update_skill_widget(skill_name: String):
	if not _skill_widgets.has(skill_name):
		return
	var widget = _skill_widgets[skill_name]
	widget["label"].text = _format_skill_text(skill_name)
	widget["bar"].value = _get_xp_percentage(skill_name)

func toggle_visible():
	visible = not visible
