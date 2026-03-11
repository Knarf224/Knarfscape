extends Resource
class_name Item

enum ItemType {
	WEAPON,
	SHIELD,
	ARMOUR,
	TOOL,
	CONSUMABLE,
	RESOURCE,
	QUEST
}

enum AttackStyle {
	NONE,
	ATTACK,
	STRENGTH,
	DEFENCE,
	RANGED,
	MAGIC
}

enum EquipSlot {
	NONE,
	MAIN_HAND,
	OFF_HAND,
	BOOTS
}

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var type: ItemType = ItemType.RESOURCE
@export var max_stack: int = 1
@export var value: int = 0

# ── COMBAT STATS ───────────────────────────────────
@export var attack_bonus: int = 0
@export var defence_bonus: int = 0
@export var strength_bonus: int = 0
@export var damage_min: float = 0.0
@export var damage_max: float = 0.0
@export var attack_range: float = 0.0

# ── EQUIPMENT ──────────────────────────────────────
@export var equip_slot: EquipSlot = EquipSlot.NONE
@export var attack_style: AttackStyle = AttackStyle.NONE

# ── CONSUMABLE ─────────────────────────────────────
@export var heal_amount: int = 0

# ── SKILL REQUIREMENTS ─────────────────────────────
@export var required_skill: String = ""
@export var required_level: int = 0

# ── HELPERS ────────────────────────────────────────
func is_equippable() -> bool:
	return equip_slot != EquipSlot.NONE

func get_attack_style_skill() -> String:
	match attack_style:
		AttackStyle.ATTACK: return "attack"
		AttackStyle.STRENGTH: return "strength"
		AttackStyle.DEFENCE: return "defence"
		AttackStyle.RANGED: return "ranged"
		AttackStyle.MAGIC: return "magic"
	return ""
