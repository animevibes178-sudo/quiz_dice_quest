extends Control

var story_pages: Array[Dictionary] = [
	{
		"title": "A PEACEFUL KINGDOM",
		"body": "Beyond the green forest stood a kingdom where the people lived in peace. The king watched over his daughter, the princess, and the brave hero who protected their home.",
		"button": "Continue"
	},
	{
		"title": "THE GOBLIN'S TRICK",
		"body": "One dark evening, a mischievous goblin sneaked into the castle and kidnapped the princess. Before the guards could react, the goblin escaped into the forest toward a hidden dungeon.",
		"button": "Continue"
	},
	{
		"title": "A KING'S REQUEST",
		"body": "The worried king called the hero to the throne room. \"Please bring my daughter home safely,\" he said. The hero gripped their sword and prepared to begin the rescue.",
		"button": "Begin Adventure"
	}
]

var page_index := 0
var title_label: Label
var body_label: Label
var next_button: Button


func _ready() -> void:
	_build_interface()
	_show_page()


func _build_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var background := ColorRect.new()
	background.color = Color("#17243b")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 270)
	center.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	margin.add_child(layout)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 25)
	title_label.add_theme_color_override("font_color", Color("#d9e8ff"))
	layout.add_child(title_label)

	body_label = Label.new()
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_label.add_theme_font_size_override("font_size", 16)
	layout.add_child(body_label)

	next_button = Button.new()
	next_button.custom_minimum_size = Vector2(0, 42)
	next_button.pressed.connect(_on_next_pressed)
	layout.add_child(next_button)


func _show_page() -> void:
	var page: Dictionary = story_pages[page_index]
	title_label.text = page["title"]
	body_label.text = page["body"]
	next_button.text = page["button"]


func _on_next_pressed() -> void:
	if page_index < story_pages.size() - 1:
		page_index += 1
		_show_page()
	else:
		title_label.text = "THE RESCUE BEGINS"
		body_label.text = "Your adventure is ready to begin. The next step is to connect this story to your playable hero, forest, and dungeon scenes."
		next_button.text = "Story Complete"
		next_button.disabled = true
