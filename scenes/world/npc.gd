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
		print("Too far away to talk!")
		return

	# Show current dialogue line
	print(npc_name + ": " + dialogue[_current_line])
	_current_line = (_current_line + 1) % dialogue.size()
