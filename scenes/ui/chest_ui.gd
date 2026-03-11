extends CanvasLayer

var _chest_ref = null

@onready var item_list = $Background/VBox/ItemList
@onready var take_all_btn = $Background/VBox/Buttons/TakeAll
@onready var close_btn = $Background/VBox/Buttons/Close

func _ready():
	add_to_group("chest_ui")
	visible = false
	take_all_btn.pressed.connect(_on_take_all)
	close_btn.pressed.connect(_on_close)

func open(chest):
	_chest_ref = chest
	_refresh()
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _refresh():
	for child in item_list.get_children():
		child.queue_free()

	if _chest_ref == null:
		return

	for i in _chest_ref.contents.size():
		var slot = _chest_ref.contents[i]
		var hbox = HBoxContainer.new()

		var label = Label.new()
		label.text = slot["item"].name + " x" + str(slot["quantity"])
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var btn = Button.new()
		btn.text = "Take"
		btn.pressed.connect(_on_take_item.bind(i))

		hbox.add_child(label)
		hbox.add_child(btn)
		item_list.add_child(hbox)

func _on_take_item(index: int):
	if _chest_ref == null or index >= _chest_ref.contents.size():
		return
	var slot = _chest_ref.contents[index]
	if GameManager.inventory.add_item(slot["item"], slot["quantity"]):
		ChatLog.add_message("You take " + slot["item"].name + ".", "gather")
		_chest_ref.contents.remove_at(index)
		_refresh()
		if _chest_ref.contents.is_empty():
			_on_close()
	else:
		ChatLog.add_message("Your inventory is full!", "system")

func _on_take_all():
	if _chest_ref == null:
		return
	var taken = []
	for i in _chest_ref.contents.size():
		var slot = _chest_ref.contents[i]
		if GameManager.inventory.add_item(slot["item"], slot["quantity"]):
			ChatLog.add_message("You take " + slot["item"].name + ".", "gather")
			taken.append(i)
		else:
			ChatLog.add_message("Inventory full!", "system")
			break
	for i in taken.size():
		_chest_ref.contents.remove_at(taken[i] - i)
	_refresh()
	if _chest_ref.contents.is_empty():
		_on_close()

func _on_close():
	visible = false
	_chest_ref = null
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
