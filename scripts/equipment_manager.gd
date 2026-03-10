extends Node
class_name EquipmentManager

# ── EQUIPMENT SLOTS ────────────────────────────────
var main_hand = null   # Weapon
var off_hand = null    # Shield
var boots = null       # Boots

# ── BASE PLAYER STATS (fists) ──────────────────────
const BASE_DAMAGE_MIN: float = 1.0
const BASE_DAMAGE_MAX: float = 3.0
const BASE_ATTACK_RANGE: float = 1.5

signal equipment_changed()

# ── EQUIP ──────────────────────────────────────────
func equip_item(item) -> bool:
	if not item.is_equippable():
		ChatLog.add_message(item.name + " cannot be equipped.", "system")
		return false

	# Check level requirement
	if item.required_skill != "" and item.required_level > 0:
		var player_level = GameManager.skills.get_level(item.required_skill)
		if player_level < item.required_level:
			ChatLog.add_message(
				"You need level " + str(item.required_level) + 
				" " + item.required_skill + " to equip " + item.name + ".", 
				"system"
			)
			return false

	# Unequip whatever is in the slot first
	match item.equip_slot:
		Item.EquipSlot.MAIN_HAND:
			if main_hand != null:
				_unequip_to_inventory(main_hand)
			main_hand = item
		Item.EquipSlot.OFF_HAND:
			if off_hand != null:
				_unequip_to_inventory(off_hand)
			off_hand = item
		Item.EquipSlot.BOOTS:
			if boots != null:
				_unequip_to_inventory(boots)
			boots = item

	# Remove from inventory
	GameManager.inventory.remove_item(item.id)
	emit_signal("equipment_changed")
	ChatLog.add_message("You equipped " + item.name + ".", "system")
	return true

func unequip_slot(slot: Item.EquipSlot) -> void:
	var item = get_slot_item(slot)
	if item == null:
		return
	_unequip_to_inventory(item)
	match slot:
		Item.EquipSlot.MAIN_HAND: main_hand = null
		Item.EquipSlot.OFF_HAND: off_hand = null
		Item.EquipSlot.BOOTS: boots = null
	emit_signal("equipment_changed")
	ChatLog.add_message("You unequipped " + item.name + ".", "system")

func _unequip_to_inventory(item) -> void:
	GameManager.inventory.add_item(item, 1)

# ── GETTERS ────────────────────────────────────────
func get_slot_item(slot: Item.EquipSlot):
	match slot:
		Item.EquipSlot.MAIN_HAND: return main_hand
		Item.EquipSlot.OFF_HAND: return off_hand
		Item.EquipSlot.BOOTS: return boots
	return null

func get_damage_min() -> float:
	if main_hand != null and main_hand.damage_min > 0:
		return main_hand.damage_min + GameManager.skills.get_level("attack") * 0.3
	return BASE_DAMAGE_MIN

func get_damage_max() -> float:
	if main_hand != null and main_hand.damage_max > 0:
		return main_hand.damage_max + GameManager.skills.get_level("attack") * 0.5
	return BASE_DAMAGE_MAX

func get_attack_range() -> float:
	if main_hand != null and main_hand.attack_range > 0:
		return main_hand.attack_range
	return BASE_ATTACK_RANGE

func get_defence_bonus() -> int:
	var bonus = 0
	if main_hand != null: bonus += main_hand.defence_bonus
	if off_hand != null: bonus += off_hand.defence_bonus
	if boots != null: bonus += boots.defence_bonus
	return bonus

func get_attack_xp_skill() -> String:
	if main_hand != null:
		var style = main_hand.get_attack_style_skill()
		if style != "":
			return style
	# Fists train strength by default
	return "strength"

func has_shield() -> bool:
	return off_hand != null and off_hand.type == Item.ItemType.SHIELD
