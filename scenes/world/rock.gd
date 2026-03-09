extends ResourceNode

func _ready():
	resource_name = "Rock"
	skill_required = "mining"
	level_required = 1
	xp_reward = 35.0
	harvest_time = 5.0
	respawn_time = 20.0
	item_id = "ore"
	item_name = "Copper Ore"
	harvest_amount = 1
	interaction_distance = 3.0
	super._ready()
