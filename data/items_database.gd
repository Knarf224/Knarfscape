extends Node

# ── ITEM DEFINITIONS ───────────────────────────────
# Call these functions to get a fresh item instance

static func create_iron_longsword() -> Item:
	var item = Item.new()
	item.id = "iron_longsword"
	item.name = "Iron Longsword"
	item.description = "A sturdy iron longsword. Trains Attack."
	item.type = Item.ItemType.WEAPON
	item.max_stack = 1
	item.value = 50
	item.damage_min = 3.0
	item.damage_max = 8.0
	item.attack_range = 2.2
	item.attack_bonus = 5
	item.equip_slot = Item.EquipSlot.MAIN_HAND
	item.attack_style = Item.AttackStyle.ATTACK
	item.required_skill = "attack"
	item.required_level = 1
	return item

static func create_iron_shield() -> Item:
	var item = Item.new()
	item.id = "iron_shield"
	item.name = "Iron Shield"
	item.description = "A solid iron shield. Trains Defence."
	item.type = Item.ItemType.SHIELD
	item.max_stack = 1
	item.value = 40
	item.defence_bonus = 8
	item.attack_range = 0.0
	item.equip_slot = Item.EquipSlot.OFF_HAND
	item.attack_style = Item.AttackStyle.DEFENCE
	item.required_skill = "defence"
	item.required_level = 1
	return item

static func create_leather_boots() -> Item:
	var item = Item.new()
	item.id = "leather_boots"
	item.name = "Leather Boots"
	item.description = "Basic leather boots."
	item.type = Item.ItemType.ARMOUR
	item.max_stack = 1
	item.value = 20
	item.defence_bonus = 2
	item.equip_slot = Item.EquipSlot.BOOTS
	item.attack_style = Item.AttackStyle.NONE
	return item
