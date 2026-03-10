extends Node

const QuestClass = preload("res://scripts/quest.gd")

var active_quests: Array = []
var completed_quests: Array = []

signal quest_started(quest_name: String)
signal quest_completed(quest_name: String)

func _ready():
	_create_starter_quests()

func _create_starter_quests():
	# Quest 1 - First Blood
	var q1 = QuestClass.new()
	q1.quest_id = "first_blood"
	q1.quest_name = "First Blood"
	q1.description = "Defeat your first goblin to prove yourself."
	q1.objectives = [
		{ "description": "Defeat a Goblin", "required": 1, "current": 0, "completed": false }
	]

	# Quest 2 - Woodcutter
	var q2 = QuestClass.new()
	q2.quest_id = "woodcutter"
	q2.quest_name = "The Woodcutter"
	q2.description = "Chop some wood to gather resources."
	q2.objectives = [
		{ "description": "Gather Logs", "required": 3, "current": 0, "completed": false }
	]

	# Quest 3 - Miner
	var q3 = QuestClass.new()
	q3.quest_id = "miner"
	q3.quest_name = "The Miner"
	q3.description = "Mine some copper ore from the rocks."
	q3.objectives = [
		{ "description": "Mine Copper Ore", "required": 2, "current": 0, "completed": false }
	]

	# Auto start all starter quests
	start_quest(q1)
	start_quest(q2)
	start_quest(q3)

func start_quest(quest) -> void:
	quest.start_quest()
	ChatLog.add_message("New Quest: " + quest.quest_name, "quest")
	quest.quest_completed.connect(_on_quest_completed)
	active_quests.append(quest)
	emit_signal("quest_started", quest.quest_name)

func _on_quest_completed(quest_id: String) -> void:
	for quest in active_quests:
		if quest.quest_id == quest_id:
			active_quests.erase(quest)
			completed_quests.append(quest)
			ChatLog.add_message("Quest Complete: " + quest.quest_name + "!", "quest")
			emit_signal("quest_completed", quest.quest_name)
			break

func get_quest(quest_id: String):
	for quest in active_quests:
		if quest.quest_id == quest_id:
			return quest
	return null

func update_quest_objective(quest_id: String, objective_index: int, amount: int = 1):
	var quest = get_quest(quest_id)
	if quest:
		quest.update_objective(objective_index, amount)
