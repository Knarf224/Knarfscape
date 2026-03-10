extends CanvasLayer

@onready var slot_list = $Background/SlotList

var _slot_buttons: Dictionary = {}

const SLOT_NAMES = {
	Item.EquipSlot.MAIN_HAND: "Main Hand",
	Item.EquipSlot.OFF_HAND: "Off Hand",
	Item.EquipSlot.BOOTS: "Boots",
}

func _ready():
	add_to_group("equipment_ui")
	await get_tree().process_frame
	_build_slots()
	GameManager.equipment.equipment_changed.connect(_refresh)

func _build_slots():
	for child in slot_list.get_children():
		child.queue_free()
	_slot_buttons.clear()

	for slot in SLOT_NAMES.keys():
		# Slot container
		var container = VBoxContainer.new()
		container.custom_minimum_size = Vector2(180, 0)

		# Slot label
		var label = Label.new()
		label.add_theme_font_size_override("font_size", 11)
		label.text = SLOT_NAMES[slot] + ": Empty"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		container.add_child(label)

		# Unequip button
		var button = Button.new()
		button.text = "Unequip"
		button.visible = false
		button.add_theme_font_size_override("font_size", 11)
		button.pressed.connect(_on_unequip_pressed.bind(slot))
		container.add_child(button)

		# Spacer
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 8)
		container.add_child(spacer)

		slot_list.add_child(container)
		_slot_buttons[slot] = {
			"label": label,
			"button": button
		}

	_refresh()

func _refresh():
	for slot in SLOT_NAMES.keys():
		var item = GameManager.equipment.get_slot_item(slot)
		var widgets = _slot_buttons[slot]
		if item != null:
			widgets["label"].text = SLOT_NAMES[slot] + ":\n" + item.name
			widgets["button"].visible = true
		else:
			widgets["label"].text = SLOT_NAMES[slot] + ": Empty"
			widgets["button"].visible = false

func _on_unequip_pressed(slot: Item.EquipSlot):
	GameManager.equipment.unequip_slot(slot)

func toggle_visible():
	visible = not visible
