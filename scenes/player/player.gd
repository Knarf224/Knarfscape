extends CharacterBody3D

# ── STATS ──────────────────────────────────────────
const WALK_SPEED = 5.0
const RUN_SPEED = 9.0
const JUMP_VELOCITY = 5.0
const GRAVITY = 9.8
const MOUSE_SENSITIVITY = 0.003
const CAMERA_MIN_PITCH = -40.0
const CAMERA_MAX_PITCH = 60.0

# ── NODE REFERENCES ────────────────────────────────
@onready var spring_arm = $SpringArm3D
@onready var camera = $SpringArm3D/Camera3D

# ── INTERNAL STATE ─────────────────────────────────
var _mouse_captured := false
var _camera_pitch := 0.0

# ──────────────────────────────────────────────────
func _ready():
	_capture_mouse()

# ── INPUT ──────────────────────────────────────────
func _input(event):
	# Rotate camera with mouse movement
	if event is InputEventMouseMotion and _mouse_captured:
		# Left/right rotates the whole player
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# Up/down tilts the spring arm
		_camera_pitch -= event.relative.y * MOUSE_SENSITIVITY
		_camera_pitch = clamp(
			_camera_pitch,
			deg_to_rad(CAMERA_MIN_PITCH),
			deg_to_rad(CAMERA_MAX_PITCH)
		)
		spring_arm.rotation.x = _camera_pitch

	# Press Escape to release mouse
	if event.is_action_pressed("ui_cancel"):
		_release_mouse()

# ── PHYSICS LOOP ───────────────────────────────────
func _physics_process(delta):
	_handle_gravity(delta)
	_handle_movement()
	_handle_jump()
	move_and_slide()

# ── MOVEMENT ───────────────────────────────────────
func _handle_movement():
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_forward", "move_back")

	# Is the player holding shift to run?
	var speed = RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED

	if input_dir != Vector2.ZERO:
		# Move relative to where the player is facing
		var direction = (
			transform.basis * Vector3(input_dir.x, 0, input_dir.y)
		).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# Smoothly slow down when no input
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

# ── MOUSE CAPTURE HELPERS ──────────────────────────
func _capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_mouse_captured = true

func _release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_mouse_captured = false
