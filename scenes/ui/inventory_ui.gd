extends CanvasLayer

@onready var grid = $Background/Grid

func _ready():
	GameManager.inventory.inventory_changed.connect(_refresh)
	_refresh()

func _refresh():
	# Clear grid
	for child in grid.get_children():
		child.queue_free()

	# Rebuild from inventory data
	for slot in GameManager.inventory.slots:
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(38, 38)

		var label = Label.new()
		label.add_theme_font_size_override("font_size", 10)
		label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

		if slot != null:
			label.text = slot["item"].name.left(6) + "\nx" + str(slot["quantity"])
		else:
			label.text = ""

		panel.add_child(label)
		grid.add_child(panel)

func toggle_visible():
	visible = not visible
