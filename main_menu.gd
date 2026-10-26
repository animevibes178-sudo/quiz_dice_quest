extends Control

const SAVE_PATH := "user://quiz_dice_quest.cfg"
var player_name_input: LineEdit
var settings_panel: PanelContainer
var about_panel: PanelContainer
var music_toggle: CheckButton
var fullscreen_toggle: CheckButton
var volume_slider: HSlider
var status_label: Label
var menu_hero: TextureRect
var title_label: Label
var menu_card: PanelContainer

func _ready() -> void:
	_build_menu()
	_load_settings()
	_play_menu_animations()
	_animate_menu_hero()

func _play_menu_animations() -> void:
	var intro := create_tween()
	intro.set_parallel(true)
	intro.tween_property(menu_card, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	intro.tween_property(menu_card, "position:y", menu_card.position.y - 28, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var glow := create_tween().set_loops()
	glow.tween_property(title_label, "modulate", Color("#ffe7a0"), 1.25).set_trans(Tween.TRANS_SINE)
	glow.tween_property(title_label, "modulate", Color.WHITE, 1.25).set_trans(Tween.TRANS_SINE)

func _animate_menu_hero() -> void:
	var frame := 1
	while is_instance_valid(menu_hero):
		var path := "res://hero_pack/hero/frames/idle/hero_idle_%02d.png" % frame
		if ResourceLoader.exists(path):
			menu_hero.texture = load(path)
		frame = (frame % 8) + 1
		await get_tree().create_timer(0.14).timeout

func _build_menu() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := TextureRect.new()
	bg.name = "MenuBackground"
	var bg_path := "res://Kingdom_Environments/Environments_1920x1080/01_Kingdom_Inside.png"
	if ResourceLoader.exists(bg_path):
		bg.texture = load(bg_path)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(bg)
	bg.pivot_offset = Vector2(640, 360)
	var bg_tween := create_tween().set_loops()
	bg_tween.tween_property(bg, "scale", Vector2(1.035, 1.035), 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	bg_tween.tween_property(bg, "scale", Vector2.ONE, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.08, 0.72)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var card := PanelContainer.new()
	menu_card = card
	card.custom_minimum_size = Vector2(470, 0)
	card.modulate.a = 0.0
	card.position.y += 28
	card.add_theme_stylebox_override("panel", _panel_style("#111b2de8", "#e8c879"))
	center.add_child(card)

	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", 28)
	pad.add_theme_constant_override("margin_right", 28)
	pad.add_theme_constant_override("margin_top", 24)
	pad.add_theme_constant_override("margin_bottom", 24)
	card.add_child(pad)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	pad.add_child(col)

	var small_title := Label.new()
	small_title.text = "A FANTASY DICE ADVENTURE"
	small_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	small_title.add_theme_font_size_override("font_size", 14)
	small_title.add_theme_color_override("font_color", Color("#f4d58d"))
	col.add_child(small_title)

	var title := Label.new()
	title_label = title
	title.text = "QUIZ DICE QUEST"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#ffffff"))
	col.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "THE RESCUE OF THE PRINCESS"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color("#f4d58d"))
	col.add_child(subtitle)

	menu_hero = TextureRect.new()
	menu_hero.custom_minimum_size = Vector2(0, 118)
	menu_hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	menu_hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	menu_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	col.add_child(menu_hero)

	var divider := HSeparator.new()
	col.add_child(divider)

	var name_label := Label.new()
	name_label.text = "PLAYER NAME"
	name_label.add_theme_color_override("font_color", Color("#e8edf5"))
	col.add_child(name_label)

	player_name_input = LineEdit.new()
	player_name_input.placeholder_text = "Enter your hero name"
	player_name_input.max_length = 18
	player_name_input.text = "Hero"
	col.add_child(player_name_input)

	var new_game := _make_button("NEW GAME")
	new_game.pressed.connect(_start_new_game)
	col.add_child(new_game)

	var continue_game := _make_button("CONTINUE")
	continue_game.pressed.connect(_continue_game)
	col.add_child(continue_game)

	var settings_button := _make_button("SETTINGS")
	settings_button.pressed.connect(_toggle_settings)
	col.add_child(settings_button)

	var about_button := _make_button("ABOUT")
	about_button.pressed.connect(_toggle_about)
	col.add_child(about_button)

	var quit_button := _make_button("QUIT")
	quit_button.pressed.connect(func(): get_tree().quit())
	col.add_child(quit_button)

	status_label = Label.new()
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", Color("#f5d58a"))
	col.add_child(status_label)

	settings_panel = _build_settings_panel()
	settings_panel.visible = false
	add_child(settings_panel)
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	settings_panel.position = Vector2(-220, -150)
	settings_panel.custom_minimum_size = Vector2(440, 300)

	about_panel = _build_about_panel()
	about_panel.visible = false
	add_child(about_panel)
	about_panel.set_anchors_preset(Control.PRESET_CENTER)
	about_panel.position = Vector2(-220, -115)
	about_panel.custom_minimum_size = Vector2(440, 230)

func _panel_style(fill: String, edge: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill)
	style.border_color = Color(edge)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func _make_button(caption: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 44)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color("#ffffff"))
	button.add_theme_stylebox_override("normal", _panel_style("#263954", "#9db4d0"))
	button.add_theme_stylebox_override("hover", _panel_style("#35577c", "#f4d58d"))
	button.add_theme_stylebox_override("pressed", _panel_style("#17263b", "#f4d58d"))
	button.pivot_offset = Vector2(200, 22)
	button.mouse_entered.connect(func():
		var tween := create_tween()
		tween.tween_property(button, "scale", Vector2(1.025, 1.025), 0.12)
	)
	button.mouse_exited.connect(func():
		var tween := create_tween()
		tween.tween_property(button, "scale", Vector2.ONE, 0.12)
	)
	return button

func _build_settings_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("#111b2d", "#e8c879"))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 10)
	panel.add_child(col)
	var heading := Label.new()
	heading.text = "SETTINGS"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 22)
	col.add_child(heading)
	music_toggle = CheckButton.new()
	music_toggle.text = "Music enabled"
	music_toggle.button_pressed = true
	col.add_child(music_toggle)
	fullscreen_toggle = CheckButton.new()
	fullscreen_toggle.text = "Fullscreen"
	fullscreen_toggle.button_pressed = false
	col.add_child(fullscreen_toggle)
	var volume_label := Label.new()
	volume_label.text = "Master volume"
	col.add_child(volume_label)
	volume_slider = HSlider.new()
	volume_slider.min_value = 0
	volume_slider.max_value = 100
	volume_slider.value = 80
	volume_slider.step = 5
	col.add_child(volume_slider)
	var buttons := HBoxContainer.new()
	col.add_child(buttons)
	var save_button := _make_button("SAVE")
	save_button.pressed.connect(_save_settings)
	buttons.add_child(save_button)
	var close_button := _make_button("CLOSE")
	close_button.pressed.connect(func(): settings_panel.visible = false)
	buttons.add_child(close_button)
	return panel

func _build_about_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style("#111b2d", "#e8c879"))
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	var heading := Label.new()
	heading.text = "ABOUT THE GAME"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 22)
	col.add_child(heading)
	var description := Label.new()
	description.text = "Quiz Dice Quest: The Rescue of the Princess\nA fantasy board adventure where you roll dice, answer quiz questions, face monsters, and journey toward the dungeon.\n\nMade as a Godot game project."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(description)
	var close_button := _make_button("CLOSE")
	close_button.pressed.connect(func(): about_panel.visible = false)
	col.add_child(close_button)
	return panel

func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		player_name_input.text = str(config.get_value("player", "name", "Hero"))
		music_toggle.button_pressed = bool(config.get_value("settings", "music", true))
		fullscreen_toggle.button_pressed = bool(config.get_value("settings", "fullscreen", false))
		volume_slider.value = float(config.get_value("settings", "volume", 80))
	_apply_settings()

func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("player", "name", _player_name())
	config.set_value("settings", "music", music_toggle.button_pressed)
	config.set_value("settings", "fullscreen", fullscreen_toggle.button_pressed)
	config.set_value("settings", "volume", volume_slider.value)
	var error := config.save(SAVE_PATH)
	if error == OK:
		_apply_settings()
		status_label.text = "Settings saved."
	else:
		status_label.text = "Could not save settings."

func _apply_settings() -> void:
	if fullscreen_toggle.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_mute(bus, not music_toggle.button_pressed)
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume_slider.value / 100.0, 0.001)))

func _player_name() -> String:
	var value := player_name_input.text.strip_edges()
	return value if not value.is_empty() else "Hero"

func _save_player_name() -> void:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	config.set_value("player", "name", _player_name())
	config.save(SAVE_PATH)

func _start_new_game() -> void:
	_save_player_name()
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	config.set_value("game", "started", true)
	config.set_value("game", "step", 0)
	config.save(SAVE_PATH)
	get_tree().change_scene_to_file("res://intro_story.tscn")

func _continue_game() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK and bool(config.get_value("game", "started", false)):
		get_tree().change_scene_to_file("res://game_board.tscn")
	else:
		status_label.text = "No saved adventure yet. Choose NEW GAME first."

func _toggle_settings() -> void:
	settings_panel.visible = not settings_panel.visible
	about_panel.visible = false

func _toggle_about() -> void:
	about_panel.visible = not about_panel.visible
	settings_panel.visible = false
