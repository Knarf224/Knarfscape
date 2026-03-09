extends CharacterBody3D

# ── STATS ──────────────────────────────────────────
@export var max_health: float = 30.0
@export var move_speed: float = 3.0
@export var attack_damage: float = 3.0
@export var attack_range: float = 1.8
@export var attack_cooldown: float = 1.2
@export var xp_reward: float = 25.0
@export var enemy_name: String = "Goblin"

var current_health: float = 30.0
var _can_attack := true
var _attack_timer := 0.0

# ── AI STATE ───────────────────────────────────────
enum State { IDLE, PATROL, CHASE, ATTACK, DEAD }
var state: State = State.IDLE

var _patrol_target: Vector3
var _patrol_timer := 0.0
const PATROL_WAIT = 2.0
const GRAVITY = 9.8

# ── NODE REFERENCES ────────────────────────────────
@onready var nav_agent = $NavigationAgent3D
@onready var detection_zone = $DetectionZone

var _player = null

# ──────────────────────────────────────────────────
func _ready():
	current_health = max_health
	add_to_group("enemies")
	detection_zone.body_entered.connect(_on_body_entered_detection)
	detection_zone.body_exited.connect(_on_body_exited_detection)
	_set_new_patrol_target()

# ── MAIN LOOP ──────────────────────────────────────
func _physics_process(delta):
	if state == State.DEAD:
		return

	_handle_gravity(delta)
	_handle_attack_timer(delta)

	match state:
		State.IDLE:
			_patrol_timer -= delta
			if _patrol_timer <= 0:
				state = State.PATROL
				_set_new_patrol_target()
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase(delta)
		State.ATTACK:
			_do_attack(delta)

	move_and_slide()

# ── GRAVITY ────────────────────────────────────────
func _handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0

# ── PATROL ─────────────────────────────────────────
func _set_new_patrol_target():
	var random_offset = Vector3(
		randf_range(-8, 8),
		0,
		randf_range(-8, 8)
	)
	_patrol_target = global_position + random_offset
	_patrol_timer = PATROL_WAIT

func _do_patrol(delta):
	nav_agent.target_position = _patrol_target
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	velocity.x = direction.x * (move_speed * 0.5)
	velocity.z = direction.z * (move_speed * 0.5)

	if global_position.distance_to(_patrol_target) < 1.5:
		state = State.IDLE
		velocity.x = 0
		velocity.z = 0

# ── CHASE ──────────────────────────────────────────
func _do_chase(delta):
	if _player == null:
		state = State.PATROL
		return

	var dist = global_position.distance_to(_player.global_position)

	if dist <= attack_range:
		state = State.ATTACK
		velocity.x = 0
		velocity.z = 0
		return

	nav_agent.target_position = _player.global_position
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	# Face the player
	var look_target = _player.global_position
	look_target.y = global_position.y
	look_at(look_target, Vector3.UP)

# ── ATTACK ─────────────────────────────────────────
func _do_attack(delta):
	if _player == null:
		state = State.CHASE
		return

	var dist = global_position.distance_to(_player.global_position)

	# Player moved out of range
	if dist > attack_range + 0.5:
		state = State.CHASE
		return

	# Face the player
	var look_target = _player.global_position
	look_target.y = global_position.y
	look_at(look_target, Vector3.UP)

	if _can_attack:
		_can_attack = false
		_attack_timer = attack_cooldown
		# Deal damage to player
		if GameManager.stats:
			var defence_reduction = GameManager.skills.get_level("defence") * 0.2
			var final_damage = max(1.0, attack_damage - defence_reduction)
			GameManager.stats.take_damage(final_damage)
			print(enemy_name + " hits player for " + str(final_damage) + " damage! Player HP: " + str(GameManager.stats.health_current))
			# Grant defence XP for being hit
			GameManager.skills.add_xp("defence", 3.0)

func _handle_attack_timer(delta):
	if not _can_attack:
		_attack_timer -= delta
		if _attack_timer <= 0:
			_can_attack = true

# ── TAKE DAMAGE ────────────────────────────────────
func take_damage(amount: float):
	if state == State.DEAD:
		return

	current_health -= amount
	print(enemy_name + " takes " + str(amount) + " damage! HP: " + str(current_health) + "/" + str(max_health))

	# Always chase when hit
	if _player == null:
		_player = get_tree().get_first_node_in_group("players")
	state = State.CHASE

	if current_health <= 0:
		_die()

# ── DEATH ──────────────────────────────────────────
func _die():
	state = State.DEAD
	velocity = Vector3.ZERO
	print(enemy_name + " has been defeated!")

	# Grant XP rewards
	if GameManager.skills:
		GameManager.skills.add_xp("hitpoints", xp_reward * 0.33)
		GameManager.skills.add_xp("attack", xp_reward * 0.33)
		GameManager.skills.add_xp("strength", xp_reward * 0.33)

	# Remove from scene after short delay
	await get_tree().create_timer(0.5).timeout
	queue_free()

# ── DETECTION ──────────────────────────────────────
func _on_body_entered_detection(body):
	if body.is_in_group("players"):
		_player = body
		state = State.CHASE
		print(enemy_name + " spotted the player!")

func _on_body_exited_detection(body):
	if body.is_in_group("players"):
		_player = null
		state = State.PATROL
		print(enemy_name + " lost sight of player")
