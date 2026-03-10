extends Node

const PlayerStatsClass = preload("res://scripts/player_stats.gd")
const SkillSystemClass = preload("res://scripts/skill_system.gd")
const InventoryClass = preload("res://scripts/inventory.gd")
const EquipmentManagerClass = preload("res://scripts/equipment_manager.gd")

var stats = null
var skills = null
var inventory = null
var equipment = null

func _ready() -> void:
	_initialize_systems()

func _initialize_systems() -> void:
	stats = PlayerStatsClass.new()

	skills = SkillSystemClass.new()
	add_child(skills)

	inventory = InventoryClass.new()
	add_child(inventory)

	equipment = EquipmentManagerClass.new()
	add_child(equipment)

	skills.skill_leveled_up.connect(_on_skill_leveled_up)

	var hp_level = skills.get_level("hitpoints")
	stats.update_max_health_from_hitpoints(hp_level)
	stats.health_current = stats.health_max
	
		# Give player starter items
	inventory.add_item(ItemsDatabase.create_iron_longsword())
	inventory.add_item(ItemsDatabase.create_iron_shield())
	inventory.add_item(ItemsDatabase.create_leather_boots())

	print("=== Knarfscape systems ready ===")

func _on_skill_leveled_up(skill_name: String, new_level: int) -> void:
	if skill_name == "hitpoints":
		stats.update_max_health_from_hitpoints(new_level)
		ChatLog.add_message("Max HP increased to " + str(int(stats.health_max)) + "!", "xp")
