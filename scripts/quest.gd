extends Resource
class_name Quest

enum Status { INACTIVE, ACTIVE, COMPLETED, FAILED }

@export var quest_id: String = ""
@export var quest_name: String = ""
@export var description: String = ""
@export var status: Status = Status.INACTIVE

# Objectives are dictionaries:
# { "description": String, "required": int, "current": int, "completed": bool }
@export var objectives: Array = []

signal objective_updated(quest_id: String)
signal quest_completed(quest_id: String)

func start_quest() -> void:
	status = Status.ACTIVE
	ChatLog.add_message("Quest started: " + quest_name, "quest")

func update_objective(index: int, amount: int = 1) -> void:
	if status != Status.ACTIVE:
		return
	if index >= objectives.size():
		return

	objectives[index]["current"] = min(
		objectives[index]["current"] + amount,
		objectives[index]["required"]
	)

	if objectives[index]["current"] >= objectives[index]["required"]:
		objectives[index]["completed"] = true
		ChatLog.add_message("Objective complete: " + objectives[index]["description"], "quest")

	emit_signal("objective_updated", quest_id)
	_check_completion()

func _check_completion() -> void:
	for obj in objectives:
		if not obj["completed"]:
			return
	status = Status.COMPLETED
	emit_signal("quest_completed", quest_id)

func is_complete() -> bool:
	return status == Status.COMPLETED
