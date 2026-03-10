extends StaticBody3D

var stored_items: Array = []
const INTERACT_DISTANCE: float = 3.0

func _ready():
	add_to_group("tombstones")

func store_items(inventory_slots: Array) -> void:
	stored_items.clear()
	for slot in inventory_slots:
		if slot != null:
			stored_items.append({
				"item_id": slot["item"].id,
				"item_name": slot["item"].name,
				"item_type": slot["item"].type,
				"max_stack": slot["item"].max_stack,
				"value": slot["item"].value,
				"quantity": slot["quantity"]
			})
	ChatLog.add_message("Your grave contains " + str(stored_items.size()) + " item stacks.", "system")

func interact(player) -> void:
	var dist = player.global_position.distance_to(global_position)
	if dist > INTERACT_DISTANCE:
		ChatLog.add_message("You are too far away from your grave!", "system")
		return

	# Return all items to inventory
	var recovered = 0
	for saved in stored_items:
		var item = Item.new()
		item.id = saved["item_id"]
		item.name = saved["item_name"]
		item.type = saved["item_type"]
		item.max_stack = saved["max_stack"]
		item.value = saved["value"]
		GameManager.inventory.add_item(item, saved["quantity"])
		recovered += 1

	ChatLog.add_message("Recovered " + str(recovered) + " item stacks from your grave!", "system")
	stored_items.clear()
	queue_free()
