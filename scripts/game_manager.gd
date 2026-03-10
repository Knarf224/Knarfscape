extends Node

const PlayerStatsClass = preload("res://scripts/player_stats.gd")
const SkillSystemClass = preload("res://scripts/skill_system.gd")
const InventoryClass = preload("res://scripts/inventory.gd")

var stats = null
var skills = null
var inventory = null

func _ready() -> void:
	_initialize_systems()

func _initialize_systems() -> void:
	stats = PlayerStatsClass.new()

	skills = SkillSystemClass.new()
	add_child(skills)

	inventory = InventoryClass.new()
	add_child(inventory)

	# Connect hitpoints level up to health update
	skills.skill_leveled_up.connect(_on_skill_leveled_up)

	# Set initial max health from starting hitpoints level
	var hp_level = skills.get_level("hitpoints")
	stats.update_max_health_from_hitpoints(hp_level)
	stats.health_current = stats.health_max

	print("=== Knarfscape systems ready ===")
	print("Starting HP: " + str(stats.health_current) + "/" + str(stats.health_max))

func _on_skill_leveled_up(skill_name: String, new_level: int) -> void:
	if skill_name == "hitpoints":
		stats.update_max_health_from_hitpoints(new_level)
		print("Max HP increased to " + str(stats.health_max) + "!")
