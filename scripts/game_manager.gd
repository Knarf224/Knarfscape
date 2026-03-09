extends Node

# ── PRELOAD CLASSES ────────────────────────────────
const PlayerStatsClass = preload("res://scripts/player_stats.gd")
const SkillSystemClass = preload("res://scripts/skill_system.gd")
const InventoryClass = preload("res://scripts/inventory.gd")

# ── REFERENCES TO ALL SYSTEMS ──────────────────────
var stats = null
var skills = null
var inventory = null

func _ready() -> void:
	_initialize_systems()

func _initialize_systems() -> void:
	# Create stats
	stats = PlayerStatsClass.new()
	print("PlayerStats initialized")

	# Create skill system
	skills = SkillSystemClass.new()
	add_child(skills)
	print("SkillSystem initialized - Total Level: " + str(skills.get_total_level()))

	# Create inventory
	inventory = InventoryClass.new()
	add_child(inventory)
	print("Inventory initialized - " + str(inventory.MAX_SLOTS) + " slots ready")

	print("=== Knarfscape systems ready ===")
	print("=== Knarfscape systems ready ===")
