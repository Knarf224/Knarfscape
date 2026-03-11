extends ResourceNode

func _ready():
	resource_name = "Tree"
	skill_required = "woodcutting"
	level_required = 1
	xp_reward = 25.0
	harvest_time = 4.0
	respawn_time = 15.0
	item_id = "logs"
	item_name = "Logs"
	harvest_amount = 1
	interaction_distance = 3.0
	super._ready()
	mesh = _find_mesh($tree_oak)

func _find_mesh(node):
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var result = _find_mesh(child)
		if result:
			return result
	return null
