extends Resource
class_name Item

enum ItemType {
	WEAPON,
	ARMOUR,
	TOOL,
	CONSUMABLE,
	RESOURCE,
	QUEST
}

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var type: ItemType = ItemType.RESOURCE
@export var max_stack: int = 1
@export var value: int = 0

# ── COMBAT STATS (for weapons/armour) ──────────────
@export var attack_bonus: int = 0
@export var defence_bonus: int = 0
@export var strength_bonus: int = 0

# ── SKILL REQUIREMENTS ─────────────────────────────
@export var required_skill: String = ""
@export var required_level: int = 0
