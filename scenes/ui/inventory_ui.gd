extends CanvasLayer

@onready var grid = $Background/Grid

func _ready():
	GameManager.inventory.inventory_changed.connect(_refresh)
	GameManager.equipment.equipment_changed.connect(_refresh)
	_refresh()

func _refresh():
	for child in grid.get_children():
		child.queue_free()

	for i in GameManager.inventory.slots.size():
		var slot = GameManager.inventory.slots[i]
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(38, 38)

		var label = Label.new()
		label.add_theme_font_size_override("font_size", 10)
		label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

		if slot != null:
			label.text = slot["item"].name.left(6) + "\nx" + str(slot["quantity"])
			# Make it clickable
			var button = Button.new()
			button.flat = true
			button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			button.pressed.connect(_on_item_clicked.bind(i))
			panel.add_child(button)
		else:
			label.text = ""

		panel.add_child(label)
		grid.add_child(panel)

func _on_item_clicked(slot_index: int):
	var slot = GameManager.inventory.slots[slot_index]
	if slot == null:
		return
	var item = slot["item"]
	if item.is_equippable():
		GameManager.equipment.equip_item(item)
	elif item.type == Item.ItemType.CONSUMABLE and item.heal_amount > 0:
		var healed = min(item.heal_amount, GameManager.stats.health_max - GameManager.stats.health_current)
		GameManager.stats.heal(float(item.heal_amount))
		GameManager.inventory.remove_item(item.id, 1)
		ChatLog.add_message("You eat " + item.name + " and restore " + str(int(healed)) + " HP.", "system")
	else:
		ChatLog.add_message(item.name + " cannot be used right now.", "system")

func toggle_visible():
	visible = not visible
