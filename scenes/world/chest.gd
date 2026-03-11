extends StaticBody3D

var contents: Array = []
var interaction_distance: float = 3.0

func _ready():
	add_to_group("chests")
	contents = [
		{"item": ItemsDatabase.create_tinderbox(), "quantity": 1},
		{"item": ItemsDatabase.create_lockpick(), "quantity": 3},
	]
	_apply_color($chest)

func _apply_color(node):
	if node is MeshInstance3D:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.55, 0.35, 0.15)  # warm wood brown
		mat.metallic = 0.3
		mat.roughness = 0.7
		node.material_override = mat
	for child in node.get_children():
		_apply_color(child)

func try_interact(player) -> bool:
	var dist = player.global_position.distance_to(global_position)
	if dist > interaction_distance:
		ChatLog.add_message("You are too far away!", "system")
		return false

	if contents.is_empty():
		ChatLog.add_message("The chest is empty.", "system")
		return false

	var chest_ui = get_tree().get_first_node_in_group("chest_ui")
	if chest_ui:
		chest_ui.open(self)
	return true
