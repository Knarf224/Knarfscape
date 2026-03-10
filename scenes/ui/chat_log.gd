extends CanvasLayer

@onready var message_list = $Background/Scroll/MessageList
@onready var scroll = $Background/Scroll

const MAX_MESSAGES: int = 50

const COLORS = {
	"default": Color.WHITE,
	"combat": Color(1.0, 0.4, 0.4),
	"xp": Color(0.4, 1.0, 0.4),
	"gather": Color(0.6, 0.9, 1.0),
	"quest": Color(1.0, 0.85, 0.0),
	"npc": Color(0.8, 0.6, 1.0),
	"death": Color(1.0, 0.2, 0.2),
	"system": Color(0.8, 0.8, 0.8),
}

func _ready():
	add_to_group("chat_log")
	# Wait for layout to be ready before adding messages
	await get_tree().process_frame
	await get_tree().process_frame
	add_message("Welcome to Knarfscape!", "system")
	add_message("WASD to move. E to interact. Left Click to attack. Q to lock on.", "system")

func add_message(text: String, type: String = "default") -> void:
	if message_list == null:
		return
	if message_list.get_child_count() >= MAX_MESSAGES:
		message_list.get_child(0).queue_free()
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", COLORS.get(type, Color.WHITE))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(480, 0)
	message_list.add_child(label)
	# Wait two frames to ensure layout is calculated before scrolling
	await get_tree().process_frame
	await get_tree().process_frame
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

const SCROLL_AMOUNT: int = 30

func _input(event):
	if event.is_action_pressed("scroll_up"):
		scroll.scroll_vertical = max(0, scroll.scroll_vertical - SCROLL_AMOUNT)
	if event.is_action_pressed("scroll_down"):
		scroll.scroll_vertical = min(
			int(scroll.get_v_scroll_bar().max_value),
			scroll.scroll_vertical + SCROLL_AMOUNT
		)
