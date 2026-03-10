extends Node
class_name SkillSystem

# ── XP TABLE ───────────────────────────────────────
# Each index = XP needed to reach that level (max level 50)
# Scaled to feel rewarding without being an endless grind
const XP_TABLE: Array = [
	0,        # Level 1
	83,       # Level 2
	174,      # Level 3
	276,      # Level 4
	388,      # Level 5
	512,      # Level 6
	650,      # Level 7
	801,      # Level 8
	969,      # Level 9
	1154,     # Level 10
	1358,     # Level 11
	1584,     # Level 12
	1833,     # Level 13
	2107,     # Level 14
	2411,     # Level 15
	2746,     # Level 16
	3115,     # Level 17
	3523,     # Level 18
	3973,     # Level 19
	4470,     # Level 20
	5018,     # Level 21
	5624,     # Level 22
	6291,     # Level 23
	7028,     # Level 24
	7842,     # Level 25
	8740,     # Level 26
	9730,     # Level 27
	10824,    # Level 28
	12031,    # Level 29
	13363,    # Level 30
	14833,    # Level 31
	16456,    # Level 32
	18247,    # Level 33
	20224,    # Level 34
	22406,    # Level 35
	24815,    # Level 36
	27473,    # Level 37
	30408,    # Level 38
	33648,    # Level 39
	37224,    # Level 40
	41171,    # Level 41
	45529,    # Level 42
	50339,    # Level 43
	55649,    # Level 44
	61512,    # Level 45
	67983,    # Level 46
	75127,    # Level 47
	83014,    # Level 48
	91721,    # Level 49
	101333,   # Level 50 (MAX)
]

# ── SKILL NAMES ────────────────────────────────────
const SKILLS: Array = [
	"hitpoints",
	"attack",
	"defence",
	"strength",
	"magic",
	"ranged",
	"woodcutting",
	"mining",
	"fishing",
	"cooking",
	"agility",
	"thieving",
]

# ── SKILL DATA ─────────────────────────────────────
var skills: Dictionary = {}

# ── SIGNALS ────────────────────────────────────────
signal skill_leveled_up(skill_name: String, new_level: int)
signal xp_gained(skill_name: String, amount: float)

# ──────────────────────────────────────────────────
func _ready() -> void:
	_initialize_skills()

func _initialize_skills() -> void:
	for skill in SKILLS:
		# Hitpoints starts at level 10 like OSRS
		var start_level = 10 if skill == "hitpoints" else 1
		skills[skill] = {
			"level": start_level,
			"xp": XP_TABLE[start_level - 1]
		}

# ── GAIN XP ────────────────────────────────────────
func add_xp(skill_name: String, amount: float) -> void:
	if not skills.has(skill_name):
		push_error("Unknown skill: " + skill_name)
		return

	skills[skill_name]["xp"] += amount
	emit_signal("xp_gained", skill_name, amount)
	_check_level_up(skill_name)
	ChatLog.add_message("+" + str(int(amount)) + " " + skill_name.capitalize() + " XP", "xp")

# ── LEVEL UP CHECK ─────────────────────────────────
func _check_level_up(skill_name: String) -> void:
	var current_level = skills[skill_name]["level"]
	if current_level >= 50:
		return

	var current_xp = skills[skill_name]["xp"]
	var xp_for_next = XP_TABLE[current_level]

	if current_xp >= xp_for_next:
		skills[skill_name]["level"] += 1
		var new_level = skills[skill_name]["level"]
		emit_signal("skill_leveled_up", skill_name, new_level)
		ChatLog.add_message("LEVEL UP! " + skill_name.capitalize() + " is now level " + str(new_level) + "!", "xp")
		# Check again in case of multiple level ups at once
		if new_level < 50:
			_check_level_up(skill_name)

# ── GETTERS ────────────────────────────────────────
func get_level(skill_name: String) -> int:
	if skills.has(skill_name):
		return skills[skill_name]["level"]
	return 0

func get_xp(skill_name: String) -> float:
	if skills.has(skill_name):
		return skills[skill_name]["xp"]
	return 0.0

func get_xp_to_next_level(skill_name: String) -> float:
	var level = get_level(skill_name)
	if level >= 50:
		return 0.0
	return XP_TABLE[level] - get_xp(skill_name)

func get_total_level() -> int:
	var total = 0
	for skill in SKILLS:
		total += get_level(skill)
	return total

func is_maxed(skill_name: String) -> bool:
	return get_level(skill_name) >= 50

func get_skill_list() -> Array:
	return SKILLS
