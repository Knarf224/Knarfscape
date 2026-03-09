extends Node
class_name Inventory

const MAX_SLOTS: int = 28  # 28 inventory slots

# Each slot is either null or { "item": Item, "quantity": int }
var slots: Array = []

signal item_added(item_name: String, quantity: int)
signal item_removed(item_name: String, quantity: int)
signal inventory_full()
signal inventory_changed()

func _ready() -> void:
	# Fill all slots with null to start
	slots.resize(MAX_SLOTS)
	for i in MAX_SLOTS:
		slots[i] = null

# ── ADD ITEM ───────────────────────────────────────
func add_item(item, quantity: int = 1) -> bool:
	# First try to stack with existing items
	if item.max_stack > 1:
		for i in MAX_SLOTS:
			if slots[i] != null and slots[i]["item"].id == item.id:
				slots[i]["quantity"] += quantity
				emit_signal("item_added", item.name, quantity)
				emit_signal("inventory_changed")
				print("Added " + str(quantity) + "x " + item.name + " (stacked)")
				return true

	# Find an empty slot
	for i in MAX_SLOTS:
		if slots[i] == null:
			slots[i] = { "item": item, "quantity": quantity }
			emit_signal("item_added", item.name, quantity)
			emit_signal("inventory_changed")
			print("Added " + str(quantity) + "x " + item.name + " to slot " + str(i))
			return true

	# No space found
	emit_signal("inventory_full")
	print("Inventory full! Could not add " + item.name)
	return false

# ── REMOVE ITEM ────────────────────────────────────
func remove_item(item_id: String, quantity: int = 1) -> bool:
	for i in MAX_SLOTS:
		if slots[i] != null and slots[i]["item"].id == item_id:
			if slots[i]["quantity"] > quantity:
				slots[i]["quantity"] -= quantity
			else:
				var removed_name = slots[i]["item"].name
				slots[i] = null
				emit_signal("item_removed", removed_name, quantity)
				emit_signal("inventory_changed")
			return true
	return false

# ── QUERIES ────────────────────────────────────────
func has_item(item_id: String, quantity: int = 1) -> bool:
	var total = 0
	for slot in slots:
		if slot != null and slot["item"].id == item_id:
			total += slot["quantity"]
	return total >= quantity

func get_item_count(item_id: String) -> int:
	var total = 0
	for slot in slots:
		if slot != null and slot["item"].id == item_id:
			total += slot["quantity"]
	return total

func is_full() -> bool:
	for slot in slots:
		if slot == null:
			return false
	return true

func get_used_slots() -> int:
	var count = 0
	for slot in slots:
		if slot != null:
			count += 1
	return count
