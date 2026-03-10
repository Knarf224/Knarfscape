extends StaticBody3D
class_name ResourceNode

# ── EXPORT VARS (set these per node in Inspector) ──
@export var resource_name: String = "Resource"
@export var skill_required: String = "woodcutting"
@export var level_required: int = 1
@export var xp_reward: float = 25.0
@export var harvest_time: float = 3.0
@export var respawn_time: float = 10.0
@export var item_id: String = "logs"
@export var item_name: String = "Logs"
@export var harvest_amount: int = 1
@export var interaction_distance: float = 3.0

# ── STATE ──────────────────────────────────────────
enum State { AVAILABLE, HARVESTING, DEPLETED }
var state: State = State.AVAILABLE

var _harvest_timer: float = 0.0
var _respawn_timer: float = 0.0
var _player_ref = null

# ── NODE REFS ──────────────────────────────────────
@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D

# ── SIGNALS ────────────────────────────────────────
signal resource_harvested(item_id: String, amount: int, xp: float)
signal resource_depleted()
signal resource_respawned()

# ──────────────────────────────────────────────────
func _ready():
	add_to_group("resource_nodes")

func _physics_process(delta):
	match state:
		State.HARVESTING:
			_harvest_timer -= delta
			if _harvest_timer <= 0:
				_complete_harvest()
		State.DEPLETED:
			_respawn_timer -= delta
			if _respawn_timer <= 0:
				_respawn()

# ── INTERACTION ────────────────────────────────────
func try_interact(player) -> bool:
	if state != State.AVAILABLE:
		ChatLog.add_message(resource_name + " is depleted. Respawning soon...", "system")
		return false

	# Check player skill level
	var player_level = GameManager.skills.get_level(skill_required)
	if player_level < level_required:
		ChatLog.add_message("You need level " + str(level_required) + " " + skill_required + " to gather this.", "system")
		return false

	# Check distance
	var dist = player.global_position.distance_to(global_position)
	if dist > interaction_distance:
		ChatLog.add_message("You are too far away!", "system")
		return false

	# Start harvesting
	_player_ref = player
	state = State.HARVESTING
	_harvest_timer = harvest_time
	ChatLog.add_message("You begin gathering " + resource_name + "...", "gather")
	return true

func _complete_harvest():
	# Create item and add to inventory
	var item = _create_item()
	var added = GameManager.inventory.add_item(item, harvest_amount)

	if added:
		# Award XP
		GameManager.skills.add_xp(skill_required, xp_reward)
		emit_signal("resource_harvested", item_id, harvest_amount, xp_reward)
		ChatLog.add_message("You gathered " + str(harvest_amount) + "x " + item_name + "!", "gather")
	else:
		ChatLog.add_message("Your inventory is full!", "system")
		
	# Update quest objectives based on what was gathered
	if item_id == "logs":
		QuestManager.update_quest_objective("woodcutter", 0)
	elif item_id == "ore":
		QuestManager.update_quest_objective("miner", 0)

	# Deplete the node
	state = State.DEPLETED
	_respawn_timer = respawn_time
	_respawn_timer = respawn_time
	emit_signal("resource_depleted")

	# Grey out the mesh to show it's depleted
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.5, 0.5, 0.5)
		mesh.material_override = mat

func _respawn():
	state = State.AVAILABLE
	_player_ref = null
	emit_signal("resource_respawned")

	# Restore original mesh appearance
	if mesh:
		mesh.material_override = null

	ChatLog.add_message(resource_name + " has respawned!", "system")

func _create_item():
	var item = Item.new()
	item.id = item_id
	item.name = item_name
	item.type = Item.ItemType.RESOURCE
	item.max_stack = 50
	item.value = 2
	return item
