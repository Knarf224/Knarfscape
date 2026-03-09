extends ResourceNode

func _ready():
	resource_name = "Fish Spot"
	skill_required = "fishing"
	level_required = 1
	xp_reward = 40.0
	harvest_time = 6.0
	respawn_time = 12.0
	item_id = "raw_fish"
	item_name = "Raw Fish"
	harvest_amount = 1
	interaction_distance = 3.0
	super._ready()
