extends CharacterBody3D

# ── STATS ──────────────────────────────────────────
const WALK_SPEED = 5.0
const RUN_SPEED = 9.0
const JUMP_VELOCITY = 5.0
const GRAVITY = 9.8
const MOUSE_SENSITIVITY = 0.003
const CAMERA_MIN_PITCH = -40.0
const CAMERA_MAX_PITCH = 60.0

# ── COMBAT ─────────────────────────────────────────
const ATTACK_DAMAGE = 5.0
const ATTACK_COOLDOWN = 0.6

var _can_attack := true
var _is_attacking := false
var _attack_timer := 0.0

# ── DEATH & RESPAWN ────────────────────────────────
var _is_dead := false
var _spawn_point := Vector3(0, 2, 0)

# ── NODE REFERENCES ────────────────────────────────
@onready var spring_arm = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D
@onready var hitbox = $HitBox

# ── LOCK ON ────────────────────────────────────────
var _locked_target = null
const LOCK_ON_RANGE = 15.0

# ── INTERNAL STATE ─────────────────────────────────
var _mouse_captured := false
var _camera_pitch := 0.0

# ──────────────────────────────────────────────────
func _ready():
	_capture_mouse()
	# Disable hitbox until we attack
	hitbox.monitoring = false
	hitbox.monitorable = false
	# Connect hitbox signal
	hitbox.body_entered.connect(_on_hitbox_body_entered)

# ── INPUT ──────────────────────────────────────────
func _input(event):
	if event is InputEventMouseMotion and _mouse_captured:
		if _locked_target == null:
			rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		_camera_pitch -= event.relative.y * MOUSE_SENSITIVITY
		_camera_pitch = clamp(
			_camera_pitch,
			deg_to_rad(CAMERA_MIN_PITCH),
			deg_to_rad(CAMERA_MAX_PITCH)
		)
		spring_arm.rotation.x = _camera_pitch

	if event.is_action_pressed("ui_cancel"):
		_release_mouse()

	# Attack input
	if event.is_action_pressed("attack"):
		_try_attack()

	# Lock on input
	if event.is_action_pressed("lock_on"):
		_toggle_lock_on()
		
	# Lock on input
	if event.is_action_pressed("lock_on"):
		_toggle_lock_on()

	# Interact with resource nodes and NPCs
	if event.is_action_pressed("interact"):
		_try_interact()
	
# Toggle UI panels
	if event.is_action_pressed("toggle_skills"):
		var panel = get_tree().get_first_node_in_group("skills_panel")
		if panel:
			panel.toggle_visible()

	if event.is_action_pressed("toggle_inventory"):
		var inv = get_tree().get_first_node_in_group("inventory_ui")
		if inv:
			inv.toggle_visible()

# ── PHYSICS LOOP ───────────────────────────────────
func _physics_process(delta):
	_handle_gravity(delta)
	_handle_movement()
	_handle_jump()
	_handle_attack_timer(delta)
	_handle_lock_on_tracking()
	_check_death()
	move_and_slide()

# ── MOVEMENT ───────────────────────────────────────
func _handle_movement():
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_forward", "move_back")

	var speed = RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED

	if input_dir != Vector2.ZERO:
		var direction = (
			transform.basis * Vector3(input_dir.x, 0, input_dir.y)
		).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

# ── JUMP ───────────────────────────────────────────
func _handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

# ── GRAVITY ────────────────────────────────────────
func _handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

# ── COMBAT ─────────────────────────────────────────
func _try_attack():
	if not _can_attack:
		return

	_can_attack = false
	_is_attacking = true
	_attack_timer = ATTACK_COOLDOWN

	# Enable hitbox for a brief window
	hitbox.monitoring = true
	hitbox.monitorable = true

	# Disable hitbox after a short window
	await get_tree().create_timer(0.2).timeout
	hitbox.monitoring = false
	hitbox.monitorable = false

	print("Player attacks!")

func _handle_attack_timer(delta):
	if not _can_attack:
		_attack_timer -= delta
		if _attack_timer <= 0:
			_can_attack = true
			_is_attacking = false

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		var damage = ATTACK_DAMAGE
		# Add attack level bonus damage
		if GameManager.skills:
			var attack_level = GameManager.skills.get_level("attack")
			damage += attack_level * 0.5
		body.take_damage(damage)
		print("Hit enemy for " + str(damage) + " damage!")
		# Grant XP for hitting
		if GameManager.skills:
			GameManager.skills.add_xp("attack", 4.0)
			GameManager.skills.add_xp("strength", 4.0)

# ── LOCK ON ────────────────────────────────────────
func _toggle_lock_on():
	if _locked_target != null:
		_locked_target = null
		print("Lock on released")
		return

	# Find nearest enemy in range
	var nearest = null
	var nearest_dist = LOCK_ON_RANGE

	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = enemy

	if nearest:
		_locked_target = nearest
		print("Locked on to: " + nearest.name)
	else:
		print("No enemies in range to lock on to")

func _handle_lock_on_tracking():
	if _locked_target == null:
		return

	# If target died or left the scene
	if not is_instance_valid(_locked_target):
		_locked_target = null
		return

	# Face the locked target
	var target_pos = _locked_target.global_position
	target_pos.y = global_position.y
	look_at(target_pos, Vector3.UP)

# ── MOUSE CAPTURE HELPERS ──────────────────────────
func _capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_mouse_captured = true

func _release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_mouse_captured = false

# ── INTERACTION ────────────────────────────────────
func _try_interact():
	var closest = null
	var closest_dist = 4.0

	for node in get_tree().get_nodes_in_group("resource_nodes"):
		var dist = global_position.distance_to(node.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = node

	for npc in get_tree().get_nodes_in_group("npcs"):
		var dist = global_position.distance_to(npc.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = npc

	for tombstone in get_tree().get_nodes_in_group("tombstones"):
		var dist = global_position.distance_to(tombstone.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = tombstone

	if closest != null:
		if closest.is_in_group("resource_nodes"):
			closest.try_interact(self)
		elif closest.is_in_group("npcs"):
			closest.interact(self)
		elif closest.is_in_group("tombstones"):
			closest.interact(self)
	else:
		print("Nothing nearby to interact with")

# ── DEATH & RESPAWN ────────────────────────────────
func _check_death():
	if _is_dead:
		return
	if GameManager.stats.is_dead():
		_is_dead = true
		_on_player_died()

func _on_player_died():
	print("Player has died!")
	velocity = Vector3.ZERO
	set_physics_process(false)
	set_process_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_spawn_tombstone()
	var death_screen = get_tree().get_first_node_in_group("death_screen")
	if death_screen:
		death_screen.respawn_requested.connect(_respawn, CONNECT_ONE_SHOT)
		death_screen.show_death_screen()
	else:
		await get_tree().create_timer(5.0).timeout
		_respawn()

func _spawn_tombstone():
	var tombstone_scene = preload("res://scenes/world/tombstone.tscn")
	var tombstone = tombstone_scene.instantiate()
	get_tree().current_scene.add_child(tombstone)
	tombstone.global_position = global_position
	tombstone.store_items(GameManager.inventory.slots.duplicate(true))
	for i in GameManager.inventory.slots.size():
		GameManager.inventory.slots[i] = null
	GameManager.inventory.emit_signal("inventory_changed")
	print("Your items have been dropped at your grave!")

func _respawn():
	print("Respawning player...")
	_is_dead = false
	GameManager.stats.health_current = 1.0
	var spawn = get_tree().get_first_node_in_group("spawn_points")
	if spawn:
		global_position = spawn.global_position
	else:
		global_position = _spawn_point
	set_physics_process(true)
	set_process_input(true)
	_capture_mouse()
	print("You respawned! Find your grave to recover your items.")
