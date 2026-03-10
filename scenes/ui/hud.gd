extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var stamina_bar = $StaminaBar
@onready var health_label = $HealthLabel
@onready var interaction_prompt = $InteractionPrompt

func _ready():
	# Connect to skill level up signal
	GameManager.skills.skill_leveled_up.connect(_on_skill_leveled_up)

func _process(_delta):
	_update_health_bar()
	_update_stamina_bar()
	_check_interaction_prompt()


func _update_health_bar():
	if GameManager.stats:
		health_bar.max_value = GameManager.stats.health_max
		health_bar.value = GameManager.stats.health_current
		var current = str(int(GameManager.stats.health_current))
		var maximum = str(int(GameManager.stats.health_max))
		health_label.text = "HP: " + current + "/" + maximum

func _update_stamina_bar():
	if GameManager.stats:
		stamina_bar.max_value = GameManager.stats.stamina_max
		stamina_bar.value = GameManager.stats.stamina_current

func _check_interaction_prompt():
	# Show prompt when near interactable
	var player = get_tree().get_first_node_in_group("players")
	if player == null:
		interaction_prompt.visible = false
		return

	var show_prompt = false
	for node in get_tree().get_nodes_in_group("resource_nodes"):
		var dist = player.global_position.distance_to(node.global_position)
		if dist <= node.interaction_distance:
			show_prompt = true
			break

	if not show_prompt:
		for npc in get_tree().get_nodes_in_group("npcs"):
			var dist = player.global_position.distance_to(npc.global_position)
			if dist <= 3.0:
				show_prompt = true
				break

	interaction_prompt.visible = show_prompt

func _on_skill_leveled_up(skill_name: String, new_level: int):
	ChatLog.add_message("LEVEL UP! " + skill_name.capitalize() + " → " + str(new_level), "xp")
	# We'll add a visual level up effect here in Phase 7
