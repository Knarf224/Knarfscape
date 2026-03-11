extends StaticBody3D

var is_lit: bool = false
var interaction_distance: float = 3.0

@onready var flames = $Flames
@onready var light = $OmniLight3D

func _ready():
	add_to_group("fires")

func try_interact(player) -> bool:
	var dist = player.global_position.distance_to(global_position)
	if dist > interaction_distance:
		ChatLog.add_message("You are too far away!", "system")
		return false

	if not is_lit:
		_try_light()
	else:
		_try_cook()
	return true

func _try_light():
	if not GameManager.inventory.has_item("tinderbox"):
		ChatLog.add_message("You need a tinderbox to light a fire.", "system")
		return
	if not GameManager.inventory.has_item("logs"):
		ChatLog.add_message("You need logs to light a fire.", "system")
		return

	GameManager.inventory.remove_item("logs", 1)
	is_lit = true

	flames.visible = true
	light.visible = true

	ChatLog.add_message("You light a fire!", "gather")

func _try_cook():
	if not GameManager.inventory.has_item("raw_fish"):
		ChatLog.add_message("You have no raw fish to cook.", "system")
		return

	var cooking_level = GameManager.skills.get_level("cooking")
	GameManager.inventory.remove_item("raw_fish", 1)

	# Burn chance decreases as cooking level increases
	var success_chance = min(0.5 + cooking_level * 0.02, 0.95)
	if randf() < success_chance:
		var cooked = ItemsDatabase.create_cooked_fish()
		GameManager.inventory.add_item(cooked, 1)
		GameManager.skills.add_xp("cooking", 30.0)
		ChatLog.add_message("You successfully cook a fish! (+30 Cooking XP)", "xp")
	else:
		GameManager.skills.add_xp("cooking", 5.0)
		ChatLog.add_message("You accidentally burn the fish! (+5 Cooking XP)", "system")
