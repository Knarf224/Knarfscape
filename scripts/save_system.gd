extends Node

const SAVE_PATH: String = "user://knarfscape_save.json"

# ── SAVE ───────────────────────────────────────────
func save_game() -> void:
	var save_data = {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"stats": _save_stats(),
		"skills": _save_skills(),
		"inventory": _save_inventory(),
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()
		print("Game saved successfully!")
	else:
		push_error("Failed to save game!")

# ── LOAD ───────────────────────────────────────────
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return false

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open save file!")
		return false

	var json = JSON.new()
	var result = json.parse(file.read_as_text())
	file.close()

	if result != OK:
		push_error("Failed to parse save file!")
		return false

	var data = json.get_data()
	_load_stats(data["stats"])
	_load_skills(data["skills"])
	_load_inventory(data["inventory"])
	print("Game loaded successfully!")
	return true

# ── SAVE HELPERS ───────────────────────────────────
func _save_stats() -> Dictionary:
	var s = GameManager.stats
	return {
		"health_current": s.health_current,
		"health_max": s.health_max,
		"stamina_current": s.stamina_current,
		"stamina_max": s.stamina_max,
	}

func _save_skills() -> Dictionary:
	return GameManager.skills.skills.duplicate(true)

func _save_inventory() -> Array:
	var saved_slots = []
	for slot in GameManager.inventory.slots:
		if slot == null:
			saved_slots.append(null)
		else:
			saved_slots.append({
				"item_id": slot["item"].id,
				"item_name": slot["item"].name,
				"quantity": slot["quantity"]
			})
	return saved_slots

# ── LOAD HELPERS ───────────────────────────────────
func _load_stats(data: Dictionary) -> void:
	var s = GameManager.stats
	s.health_current = data["health_current"]
	s.health_max = data["health_max"]
	s.stamina_current = data["stamina_current"]
	s.stamina_max = data["stamina_max"]

func _load_skills(data: Dictionary) -> void:
	GameManager.skills.skills = data

func _load_inventory(data: Array) -> void:
	print("Inventory load placeholder - will expand in Phase 5")
