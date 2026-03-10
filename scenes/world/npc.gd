extends StaticBody3D

@export var npc_name: String = "Wise Old Man"
@export var dialogue: Array = [
	"Welcome to Knarfscape, adventurer!",
	"There are trees to the east and rocks to the north.",
	"Beware of the goblins that roam these lands.",
	"Train your skills and grow stronger!",
]

var _current_line: int = 0
const INTERACT_DISTANCE: float = 3.0

func _ready():
	add_to_group("npcs")

func interact(player) -> void:
	var dist = player.global_position.distance_to(global_position)
	if dist > INTERACT_DISTANCE:
		ChatLog.add_message("You are too far away to talk!", "system")
		return

	# Show current dialogue line
	ChatLog.add_message(npc_name + ": " + dialogue[_current_line], "npc")
	_current_line = (_current_line + 1) % dialogue.size()
