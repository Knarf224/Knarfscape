extends Resource
class_name PlayerStats

# ── CORE STATS ─────────────────────────────────────
var health_current: float = 10.0
var health_max: float = 10.0
var stamina_current: float = 10.0
var stamina_max: float = 10.0

# ── COMBAT STATS ───────────────────────────────────
var attack_level: int = 1
var defence_level: int = 1
var strength_level: int = 1

# ── META ───────────────────────────────────────────
var player_name: String = "Player"

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

func update_max_health_from_hitpoints(hitpoints_level: int) -> void:
	# Max HP = hitpoints level directly (level 10 = 10 HP, level 50 = 50 HP)
	var new_max = float(hitpoints_level)
	if new_max > health_max:
		# Heal the difference when max HP increases
		var diff = new_max - health_max
		health_max = new_max
		health_current = min(health_current + diff, health_max)
	else:
		health_max = new_max
		health_current = min(health_current, health_max)
