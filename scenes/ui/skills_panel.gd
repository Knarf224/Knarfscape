extends CanvasLayer

@onready var skill_list = $Background/SkillList

var _skill_labels: Dictionary = {}

func _ready():
	_build_skill_list()
	GameManager.skills.skill_leveled_up.connect(_on_level_up)
	GameManager.skills.xp_gained.connect(_on_xp_gained)

func _build_skill_list():
	# Clear existing
	for child in skill_list.get_children():
		child.queue_free()
	_skill_labels.clear()

	# Build a label for each skill
	for skill_name in GameManager.skills.get_skill_list():
		var label = Label.new()
		var level = GameManager.skills.get_level(skill_name)
		label.text = skill_name.capitalize() + ": " + str(level)
		label.add_theme_font_size_override("font_size", 12)
		skill_list.add_child(label)
		_skill_labels[skill_name] = label

func _on_level_up(skill_name: String, new_level: int):
	if _skill_labels.has(skill_name):
		_skill_labels[skill_name].text = skill_name.capitalize() + ": " + str(new_level)

func _on_xp_gained(skill_name: String, _amount: float):
	# Update label to show current level
	if _skill_labels.has(skill_name):
		var level = GameManager.skills.get_level(skill_name)
		_skill_labels[skill_name].text = skill_name.capitalize() + ": " + str(level)

func toggle_visible():
	visible = not visible
