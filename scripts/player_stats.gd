extends Resource
class_name PlayerStats

# ── CORE STATS ─────────────────────────────────────
@export var health_current: float = 10.0
@export var health_max: float = 10.0
@export var stamina_current: float = 10.0
@export var stamina_max: float = 10.0

# ── COMBAT STATS ───────────────────────────────────
@export var attack_level: int = 1
@export var defence_level: int = 1
@export var strength_level: int = 1

# ── META ───────────────────────────────────────────
@export var player_name: String = "Player"
@export var total_level: int = 0

# ── METHODS ────────────────────────────────────────
func take_damage(amount: float) -> void:
	health_current = max(0, health_current - amount)

func heal(amount: float) -> void:
	health_current = min(health_max, health_current + amount)

func use_stamina(amount: float) -> void:
	stamina_current = max(0, stamina_current - amount)

func restore_stamina(amount: float) -> void:
	stamina_current = min(stamina_max, stamina_current + amount)

func is_dead() -> bool:
	return health_current <= 0
