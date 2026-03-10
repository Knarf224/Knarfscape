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
	print("Tombstone created with " + str(stored_items.size()) + " item stacks")

func interact(player) -> void:
	var dist = player.global_position.distance_to(global_position)
	if dist > INTERACT_DISTANCE:
		print("Too far away from your grave!")
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

	print("Recovered " + str(recovered) + " item stacks from your grave!")
	stored_items.clear()
	queue_free()
