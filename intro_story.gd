extends Control

const STORY_PAGES: Array[Dictionary] = [
	{
		"title": "A KINGDOM AT PEACE",
		"body": "Beyond the green forest, a peaceful kingdom flourished. The princess spent her days among the people, while the king watched over his home.",
		"background": ["kingdom", "outside", "village", "town"],
		"characters": [["princess", "happy"], ["king", "idle"]]
	},
	{
		"title": "A STRANGE SHADOW",
		"body": "One evening, a goblin crept into the kingdom. It had a wicked plan, and the castle guards did not notice it in time.",
		"background": ["kingdom", "outside", "castle", "courtyard"],
		"characters": [["goblin", "laugh"], ["princess", "normal"]]
	},
	{
		"title": "THE PRINCESS IS TAKEN!",
		"body": "The goblin grabbed the princess and fled toward the dark forest. Her cries echoed behind them as the kingdom fell into panic.",
		"background": ["kidnap", "kingdom", "forest", "outside"],
		"characters": [["goblin", "carry"], ["princess", "cry"]]
	},
	{
		"title": "A PRISONER IN THE DUNGEON",
		"body": "Far from the castle, the goblin locked the princess away in a dungeon. She hoped someone would come to rescue her.",
		"background": ["dungeon", "cave", "prison"],
		"characters": [["princess", "sad"], ["goblin", "laugh"]]
	},
	{
		"title": "THE KING'S REQUEST",
		"body": "The king called for a brave hero. \"Please, bring my daughter home safely,\" he pleaded. The hero took up their sword and accepted the mission.",
		"background": ["kingdom", "inside", "throne", "castle"],
		"characters": [["king", "talk"], ["hero", "idle"]]
	},
	{
		"title": "THE RESCUE BEGINS",
		"body": "With one sword at their side, the hero set out toward the forest and the hidden dungeon. The journey to save the princess starts now.",
		"background": ["forest", "nature", "path"],
		"characters": [["hero", "walk"]]
	}
]

var page_index := 0
var texture_paths: Array[String] = []
var background_rect: TextureRect
var shade: ColorRect
var title_label: Label
var story_label: Label
var character_row: HBoxContainer
var page_label: Label
var next_button: Button
var back_button: Button
var textures_by_key: Dictionary = {}


func _ready() -> void:
	_scan_for_art("res://")
	_build_interface()
	_show_page()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_RIGHT or event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
		_on_next_pressed()
	elif event.keycode == KEY_LEFT or event.keycode == KEY_BACKSPACE:
		_on_back_pressed()


func _scan_for_art(folder_path: String) -> void:
	var directory := DirAccess.open(folder_path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = directory.get_next()
			continue
		var full_path := folder_path.path_join(entry)
		if directory.current_is_dir():
			_scan_for_art(full_path)
		elif entry.get_extension().to_lower() in ["png", "webp", "jpg", "jpeg"]:
			texture_paths.append(full_path)
		entry = directory.get_next()
	directory.list_dir_end()


func _build_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	background_rect = TextureRect.new()
	background_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(background_rect)

	var fallback_background := ColorRect.new()
	fallback_background.color = Color("#17243b")
	fallback_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fallback_background.z_index = -1
	add_child(fallback_background)

	shade = ColorRect.new()
	shade.color = Color(0.035, 0.055, 0.09, 0.46)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var safe_area := MarginContainer.new()
	safe_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_area.add_theme_constant_override("margin_left", 30)
	safe_area.add_theme_constant_override("margin_right", 30)
	safe_area.add_theme_constant_override("margin_top", 22)
	safe_area.add_theme_constant_override("margin_bottom", 22)
	add_child(safe_area)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 10)
	safe_area.add_child(layout)

	var heading := Label.new()
	heading.text = "QUIZ DICE QUEST  •  THE RESCUE OF THE PRINCESS"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 17)
	heading.add_theme_color_override("font_color", Color("#f4d58d"))
	layout.add_child(heading)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color("#ffffff"))
	layout.add_child(title_label)

	character_row = HBoxContainer.new()
	character_row.alignment = BoxContainer.ALIGNMENT_CENTER
	character_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	character_row.add_theme_constant_override("separation", 24)
	layout.add_child(character_row)

	var story_panel := PanelContainer.new()
	story_panel.custom_minimum_size = Vector2(0, 112)
	story_panel.add_theme_stylebox_override("panel", _make_panel_style())
	layout.add_child(story_panel)

	var panel_margin := MarginContainer.new()
	panel_margin.add_theme_constant_override("margin_left", 18)
	panel_margin.add_theme_constant_override("margin_right", 18)
	panel_margin.add_theme_constant_override("margin_top", 10)
	panel_margin.add_theme_constant_override("margin_bottom", 10)
	story_panel.add_child(panel_margin)

	var panel_layout := VBoxContainer.new()
	panel_layout.add_theme_constant_override("separation", 8)
	panel_margin.add_child(panel_layout)

	story_label = Label.new()
	story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	story_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	story_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	story_label.add_theme_font_size_override("font_size", 16)
	story_label.add_theme_color_override("font_color", Color("#f7f4ed"))
	panel_layout.add_child(story_label)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 16)
	layout.add_child(footer)

	back_button = Button.new()
	back_button.text = "Back"
	back_button.custom_minimum_size = Vector2(110, 38)
	back_button.pressed.connect(_on_back_pressed)
	footer.add_child(back_button)

	page_label = Label.new()
	page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page_label.custom_minimum_size = Vector2(90, 0)
	page_label.add_theme_color_override("font_color", Color("#e2e8f0"))
	footer.add_child(page_label)

	next_button = Button.new()
	next_button.custom_minimum_size = Vector2(170, 38)
	next_button.pressed.connect(_on_next_pressed)
	footer.add_child(next_button)


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.075, 0.12, 0.88)
	style.border_color = Color("#d8b56d")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _show_page() -> void:
	var page: Dictionary = STORY_PAGES[page_index]
	title_label.text = str(page["title"])
	story_label.text = str(page["body"])
	page_label.text = "%d / %d" % [page_index + 1, STORY_PAGES.size()]
	back_button.disabled = page_index == 0
	next_button.text = "Begin Adventure" if page_index == STORY_PAGES.size() - 1 else "Continue"
	_set_background(page["background"])
	_set_characters(page["characters"])


func _set_background(keywords: Array) -> void:
	var path := _find_art(keywords, ["environment", "background", "scene"])
	if path.is_empty():
		background_rect.texture = null
		background_rect.modulate = Color.WHITE
		return
	var resource := load(path)
	if resource is Texture2D:
		background_rect.texture = resource
		background_rect.modulate = Color.WHITE


func _set_characters(character_specs: Array) -> void:
	for child in character_row.get_children():
		child.queue_free()
	for spec in character_specs:
		var keywords: Array = spec
		var path := _find_art(keywords, ["sprite", "frames", "portrait", "princess", "king", "hero", "goblin"])
		if path.is_empty():
			continue
		var resource := load(path)
		if not resource is Texture2D:
			continue
		var portrait := TextureRect.new()
		portrait.texture = resource
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		portrait.custom_minimum_size = Vector2(150, 150)
		portrait.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		character_row.add_child(portrait)


func _find_art(keywords: Array, preferred_path_words: Array) -> String:
	var best_path := ""
	var best_score := -1
	for candidate in texture_paths:
		var lower_path := candidate.to_lower()
		var score := 0
		var matches := true
		for keyword in keywords:
			if not lower_path.contains(str(keyword).to_lower()):
				matches = false
				break
		if not matches:
			continue
		for preferred in preferred_path_words:
			if lower_path.contains(str(preferred).to_lower()):
				score += 2
		if lower_path.contains("/frames/"):
			score += 1
		if lower_path.contains("portrait"):
			score -= 2
		if score > best_score:
			best_score = score
			best_path = candidate
	return best_path


func _on_back_pressed() -> void:
	if page_index > 0:
		page_index -= 1
		_show_page()


func _on_next_pressed() -> void:
	if page_index < STORY_PAGES.size() - 1:
		page_index += 1
		_show_page()
	else:
		page_index = 0
		_show_page()
