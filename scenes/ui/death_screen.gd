extends CanvasLayer

@onready var respawn_label = $RespawnLabel

const RESPAWN_TIME = 5.0
var _timer = 0.0
var _is_active = false

signal respawn_requested()

func _ready():
	visible = false

func _process(delta):
	if not _is_active:
		return
	_timer -= delta
	respawn_label.text = "Respawning in " + str(int(ceil(_timer))) + "..."
	if _timer <= 0:
		_is_active = false
		visible = false
		emit_signal("respawn_requested")

func show_death_screen():
	visible = true
	_is_active = true
	_timer = RESPAWN_TIME
