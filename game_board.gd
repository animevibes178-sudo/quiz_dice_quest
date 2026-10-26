extends Control

const HERO_IDLE := "res://hero_pack/hero/frames/idle/hero_idle_%02d.png"
const HERO_WALK := "res://hero_pack/hero/frames/walk/hero_walk_%02d.png"
const GOBLIN_IDLE := "res://Godot_Monster_Assets/monsters/goblin/frames/goblin_idle.png"
const QUESTIONS := [
	{"subject":"Technology","difficulty":1,"q":"Which command retrieves data from a database?","answers":["SELECT","DELETE","DROP"],"correct":0},
	{"subject":"Tech","difficulty":1,"q":"Which part of a computer runs program instructions?","answers":["Monitor","CPU","Keyboard"],"correct":1},
	{"subject":"Tech","difficulty":2,"q":"What does HTML mainly structure?","answers":["Web pages","Databases","Networks"],"correct":0},
	{"subject":"Tech","difficulty":1,"q":"Which one is an input device?","answers":["Speaker","Monitor","Keyboard"],"correct":2},
	{"subject":"Tech","difficulty":2,"q":"Which symbol commonly ends a SQL statement?","answers":[";","?","@"],"correct":0},
	{"subject":"Science","difficulty":1,"q":"Which planet is closest to the Sun?","answers":["Mercury","Earth","Mars"],"correct":0},
	{"subject":"Science","difficulty":2,"q":"What gas do plants absorb for photosynthesis?","answers":["Carbon dioxide","Oxygen","Helium"],"correct":0},
	{"subject":"Science","difficulty":3,"q":"What is the chemical symbol for gold?","answers":["Au","Ag","Gd"],"correct":0},
	{"subject":"Math","difficulty":1,"q":"What is 9 × 6?","answers":["54","56","63"],"correct":0},
	{"subject":"Math","difficulty":2,"q":"What is 15% of 200?","answers":["30","15","20"],"correct":0},
	{"subject":"Math","difficulty":3,"q":"Solve: 3x + 7 = 31. What is x?","answers":["8","6","10"],"correct":0},
	{"subject":"English","difficulty":1,"q":"What is the plural of child?","answers":["Children","Childs","Childrens"],"correct":0},
	{"subject":"English","difficulty":2,"q":"Which word is an adverb?","answers":["Slowly","Teacher","Beautiful"],"correct":0},
	{"subject":"English","difficulty":3,"q":"Choose the correct word: They left ___ bags at home.","answers":["their","there","they're"],"correct":0},
	{"subject":"World","difficulty":1,"q":"What is the capital of Japan?","answers":["Tokyo","Seoul","Beijing"],"correct":0},
	{"subject":"World","difficulty":2,"q":"In what year did World War II end?","answers":["1945","1939","1950"],"correct":0},
	{"subject":"World","difficulty":3,"q":"Which line divides Earth into Northern and Southern Hemispheres?","answers":["Equator","Prime Meridian","Tropic of Cancer"],"correct":0}
]

var step := 0
var rolling := false
var awaiting_answer := false
var question_index := 0
var hero: TextureRect
var goblin: TextureRect
var goblin_animation_paths := [
	"res://Godot_Monster_Assets/monsters/goblin/frames/goblin_idle.png",
	"res://Godot_Monster_Assets/monsters/goblin/frames/goblin_walk.png",
	"res://Godot_Monster_Assets/monsters/goblin/frames/goblin_run.png"
]
var hero_idle_frame := 1
var hero_animating := false
var dice_label: Label
var status_label: Label
var path_grid: Control
var roll_button: Button
var answer_box: VBoxContainer
var rng := RandomNumberGenerator.new()
var spaces: Array[PanelContainer] = []
var board_background: TextureRect
var battle_overlay: ColorRect
var battle_hero: TextureRect
var battle_monster: TextureRect
var battle_title: Label
var battle_log: Label
var hero_stats_label: Label
var battle_stats_label: Label
var hp_bar: ProgressBar
var exp_bar: ProgressBar
var quiz_popup: PanelContainer
var hero_max_hp := 80
var hero_hp := 80
var hero_attack := 8
var hero_defense := 2
var goblin_max_hp := 48
var goblin_hp := 48
var goblin_attack := 12
var goblin_defense := 3
var stage := 1
var stage_count := 5
var endless_mode := false
var tile_events: Array[String] = []
var experience := 0
var hero_level := 1
var win_streak := 0
var fifty_fifty_charges := 1
var questions_right: Dictionary = {}
var questions_seen: Dictionary = {}
var missed_questions: Array[Dictionary] = []
var stage_snapshot: Dictionary = {}
var boss_shield_bonus := 0
var current_battle_is_boss := false
var question_timer_id := 0
var question_timer_label: Label
var question_help_button: Button

func _ready() -> void:
	rng.randomize()
	_build_ui()
	_start_stage(false)
	_update_board()
	_set_status("Stage 1 begins! Roll the dice and grow stronger through quizzes and battles.")
	_start_background_motion()
	_build_battle_overlay()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := TextureRect.new()
	board_background = bg
	bg.texture = load("res://Kingdom_Environments/Environments_1920x1080/04_Forest_Nature.png")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.04, 0.08, 0.62)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)
	var main := VBoxContainer.new()
	main.add_theme_constant_override("separation", 12)
	margin.add_child(main)

	var header := HBoxContainer.new()
	main.add_child(header)
	var heading := Label.new()
	heading.text = "QUIZ DICE QUEST  •  THE RESCUE"
	heading.add_theme_font_size_override("font_size", 24)
	heading.add_theme_color_override("font_color", Color("#f5d58a"))
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	var menu_button := Button.new()
	menu_button.text = "Story"
	menu_button.pressed.connect(func(): get_tree().change_scene_to_file("res://intro_story.tscn"))
	header.add_child(menu_button)

	var content := HBoxContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 20)
	main.add_child(content)

	var board_panel := PanelContainer.new()
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_panel.add_theme_stylebox_override("panel", _panel_style("#142239", "#d7b46a"))
	content.add_child(board_panel)
	var board_margin := MarginContainer.new()
	board_margin.add_theme_constant_override("margin_left", 16)
	board_margin.add_theme_constant_override("margin_right", 16)
	board_margin.add_theme_constant_override("margin_top", 16)
	board_margin.add_theme_constant_override("margin_bottom", 16)
	board_panel.add_child(board_margin)
	var board_col := VBoxContainer.new()
	board_col.add_theme_constant_override("separation", 12)
	board_margin.add_child(board_col)
	var board_title := Label.new()
	board_title.text = "FOREST TRAIL"
	board_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	board_title.add_theme_font_size_override("font_size", 20)
	board_title.add_theme_color_override("font_color", Color("#f5d58a"))
	board_col.add_child(board_title)
	path_grid = Control.new()
	path_grid.custom_minimum_size = Vector2(650, 340)
	path_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	path_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_col.add_child(path_grid)
	for i in range(24):
		var tile := PanelContainer.new()
		tile.custom_minimum_size = Vector2(60, 58)
		tile.size = Vector2(60, 58)
		tile.add_theme_stylebox_override("panel", _panel_style("#34465b", "#66758a"))
		var tile_content := VBoxContainer.new()
		tile_content.add_theme_constant_override("separation", 0)
		tile_content.alignment = BoxContainer.ALIGNMENT_CENTER
		tile.add_child(tile_content)
		var icon := TextureRect.new()
		icon.name = "TileIcon"
		icon.custom_minimum_size = Vector2(24, 24)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tile_content.add_child(icon)
		var tile_hero := TextureRect.new()
		tile_hero.name = "TileHero"
		tile_hero.custom_minimum_size = Vector2(34, 28)
		tile_hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tile_hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tile_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tile_hero.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tile_hero.visible = false
		tile_content.add_child(tile_hero)
		var label := Label.new()
		label.name = "TileLabel"
		label.text = str(i + 1)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 11)
		tile_content.add_child(label)
		path_grid.add_child(tile)
		spaces.append(tile)
	var hint := Label.new()
	hint.text = "Fight • Heal • Quiz Chest • Trap • Lucky • Skip • Boss"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", Color("#e2e8f0"))
	board_col.add_child(hint)

	var side := PanelContainer.new()
	side.custom_minimum_size = Vector2(340, 0)
	side.add_theme_stylebox_override("panel", _panel_style("#101a2c", "#d7b46a"))
	content.add_child(side)
	var side_margin := MarginContainer.new()
	side_margin.add_theme_constant_override("margin_left", 16)
	side_margin.add_theme_constant_override("margin_right", 16)
	side_margin.add_theme_constant_override("margin_top", 14)
	side_margin.add_theme_constant_override("margin_bottom", 14)
	side.add_child(side_margin)
	var side_col := VBoxContainer.new()
	side_col.add_theme_constant_override("separation", 10)
	side_margin.add_child(side_col)
	var hero_title := Label.new()
	hero_title.text = "YOUR HERO"
	hero_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_title.add_theme_color_override("font_color", Color("#f5d58a"))
	side_col.add_child(hero_title)
	hero = TextureRect.new()
	hero.custom_minimum_size = Vector2(0, 150)
	hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	side_col.add_child(hero)
	var score := Label.new()
	score.name = "StepInfo"
	score.text = "Trail progress: 0 / 24"
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	side_col.add_child(score)
	hp_bar = ProgressBar.new()
	hp_bar.min_value = 0
	hp_bar.max_value = hero_max_hp
	hp_bar.value = hero_hp
	hp_bar.show_percentage = false
	hp_bar.custom_minimum_size = Vector2(0, 22)
	hp_bar.add_theme_stylebox_override("background", _panel_style("#3b1720", "#7f1d1d"))
	hp_bar.add_theme_stylebox_override("fill", _panel_style("#b91c1c", "#fca5a5"))
	side_col.add_child(hp_bar)
	hero_stats_label = Label.new()
	hero_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_stats_label.add_theme_color_override("font_color", Color("#e2e8f0"))
	side_col.add_child(hero_stats_label)
	exp_bar = ProgressBar.new()
	exp_bar.min_value = 0
	exp_bar.max_value = _exp_needed()
	exp_bar.value = experience
	exp_bar.show_percentage = false
	exp_bar.custom_minimum_size = Vector2(0, 14)
	exp_bar.add_theme_stylebox_override("background", _panel_style("#172554", "#1d4ed8"))
	exp_bar.add_theme_stylebox_override("fill", _panel_style("#2563eb", "#93c5fd"))
	side_col.add_child(exp_bar)
	_update_hero_stats()
	dice_label = Label.new()
	dice_label.text = "🎲  ?"
	dice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dice_label.add_theme_font_size_override("font_size", 30)
	dice_label.add_theme_color_override("font_color", Color("#f5d58a"))
	side_col.add_child(dice_label)
	roll_button = Button.new()
	roll_button.text = "ROLL DICE"
	roll_button.custom_minimum_size = Vector2(0, 48)
	roll_button.pressed.connect(_on_roll_pressed)
	side_col.add_child(roll_button)
	status_label = Label.new()
	status_label.text = ""
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size = Vector2(0, 62)
	side_col.add_child(status_label)
	var monster_title := Label.new()
	monster_title.text = "FOREST ENCOUNTER"
	monster_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	monster_title.add_theme_color_override("font_color", Color("#f5d58a"))
	side_col.add_child(monster_title)
	goblin = TextureRect.new()
	goblin.texture = load(GOBLIN_IDLE) if ResourceLoader.exists(GOBLIN_IDLE) else null
	goblin.custom_minimum_size = Vector2(0, 95)
	goblin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	goblin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	goblin.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	side_col.add_child(goblin)
	quiz_popup = PanelContainer.new()
	quiz_popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	quiz_popup.position = Vector2(-260, -190)
	quiz_popup.custom_minimum_size = Vector2(520, 380)
	quiz_popup.add_theme_stylebox_override("panel", _panel_style("#111827", "#f5d58a"))
	quiz_popup.visible = false
	add_child(quiz_popup)
	var quiz_margin := MarginContainer.new()
	quiz_margin.add_theme_constant_override("margin_left", 18)
	quiz_margin.add_theme_constant_override("margin_right", 18)
	quiz_margin.add_theme_constant_override("margin_top", 16)
	quiz_margin.add_theme_constant_override("margin_bottom", 16)
	quiz_popup.add_child(quiz_margin)
	answer_box = VBoxContainer.new()
	answer_box.add_theme_constant_override("separation", 10)
	quiz_margin.add_child(answer_box)
	_set_hero_frame(1)
	_start_idle_animation()
	_start_goblin_animation()

func _start_background_motion() -> void:
	board_background.pivot_offset = Vector2(640, 360)
	var tween := create_tween().set_loops()
	tween.tween_property(board_background, "scale", Vector2(1.025, 1.025), 7.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(board_background, "scale", Vector2.ONE, 7.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _panel_style(fill: String, edge: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill)
	style.border_color = Color(edge)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

func _start_stage(restore_snapshot: bool) -> void:
	step = 0
	var tile_count := mini(30 + (stage - 1) * 5, 50)
	tile_events.clear()
	tile_events.append("start")
	for i in range(1, tile_count - 1):
		var roll := rng.randf()
		var fight_chance := minf(0.22 + float(stage - 1) * 0.035, 0.42)
		var heal_chance := maxf(0.16 - float(stage - 1) * 0.02, 0.06)
		var event := "empty"
		if roll < fight_chance:
			event = "fight"
		elif roll < fight_chance + heal_chance:
			event = "heal"
		elif roll < fight_chance + heal_chance + 0.18:
			event = "chest"
		elif roll < fight_chance + heal_chance + 0.18 + 0.10:
			event = "trap"
		elif roll < fight_chance + heal_chance + 0.18 + 0.10 + 0.10:
			event = "lucky"
		elif roll < fight_chance + heal_chance + 0.18 + 0.10 + 0.10 + 0.06:
			event = "skip"
		tile_events.append(event)
	tile_events.append("boss")
	_rebuild_tiles(tile_count)
	stage_snapshot = {
		"hp": hero_hp, "max_hp": hero_max_hp, "attack": hero_attack, "defense": hero_defense,
		"level": hero_level, "exp": experience, "helper": fifty_fifty_charges, "streak": win_streak
	}
	if restore_snapshot:
		hero_hp = int(stage_snapshot.hp)
		hero_max_hp = int(stage_snapshot.max_hp)
		hero_attack = int(stage_snapshot.attack)
		hero_defense = int(stage_snapshot.defense)
		hero_level = int(stage_snapshot.level)
		experience = int(stage_snapshot.exp)
		fifty_fifty_charges = int(stage_snapshot.helper)
		win_streak = int(stage_snapshot.streak)

func _rebuild_tiles(count: int) -> void:
	while spaces.size() > count:
		var old_tile = spaces.pop_back()
		old_tile.queue_free()
	while spaces.size() < count:
		var i := spaces.size()
		var tile := PanelContainer.new()
		tile.custom_minimum_size = Vector2(60, 58)
		tile.size = Vector2(60, 58)
		tile.add_theme_stylebox_override("panel", _panel_style("#34465b", "#66758a"))
		var tile_content := VBoxContainer.new()
		tile_content.add_theme_constant_override("separation", 0)
		tile_content.alignment = BoxContainer.ALIGNMENT_CENTER
		tile.add_child(tile_content)
		var icon := TextureRect.new()
		icon.name = "TileIcon"
		icon.custom_minimum_size = Vector2(24, 24)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tile_content.add_child(icon)
		var tile_hero := TextureRect.new()
		tile_hero.name = "TileHero"
		tile_hero.custom_minimum_size = Vector2(34, 28)
		tile_hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tile_hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tile_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tile_hero.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tile_hero.visible = false
		tile_content.add_child(tile_hero)
		var label := Label.new()
		label.name = "TileLabel"
		label.text = str(i + 1)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 11)
		tile_content.add_child(label)
		path_grid.add_child(tile)
		spaces.append(tile)
	_layout_winding_path()

func _layout_winding_path() -> void:
	if not is_instance_valid(path_grid):
		return
	var columns := 10
	var tile_size := Vector2(60, 58)
	var gap := 5.0
	for i in range(spaces.size()):
		var row := int(i / columns)
		var col := i % columns
		if row % 2 == 1:
			col = columns - 1 - col
		var tile := spaces[i]
		tile.position = Vector2(col * (tile_size.x + gap), row * (tile_size.y + gap))
		tile.size = tile_size

func _update_board() -> void:
	_layout_winding_path()
	for i in range(spaces.size()):
		var tile := spaces[i]
		var content := tile.get_child(0) as VBoxContainer
		var icon := content.get_node("TileIcon") as TextureRect
		var tile_hero := content.get_node("TileHero") as TextureRect
		var label := content.get_node("TileLabel") as Label
		var event_name: String = tile_events[i] if i < tile_events.size() else "empty"
		var icon_map := {"start":"start","boss":"boss","fight":"goblin","chest":"scroll","heal":"potion","trap":"empty","lucky":"chest","skip":"scroll","empty":"empty"}
		var icon_name: String = icon_map.get(event_name, "empty")
		var icon_path := "res://Dungeon_Tiles_and_Dice/tiles/128/%s.png" % icon_name
		if ResourceLoader.exists(icon_path):
			icon.texture = load(icon_path)
		else:
			icon.texture = null
		tile_hero.visible = i == step
		tile_hero.texture = hero.texture if i == step and is_instance_valid(hero) else null
		label.text = str(i + 1)
		label.add_theme_color_override("font_color", Color("#fef3c7") if i == step else Color("#e2e8f0"))
		if i == step:
			tile.add_theme_stylebox_override("panel", _panel_style("#2878b8", "#ffffff"))
			tile.scale = Vector2(1.06, 1.06)
		elif event_name == "fight" or event_name == "boss":
			tile.add_theme_stylebox_override("panel", _panel_style("#713c42", "#dc8b7f"))
			tile.scale = Vector2.ONE
		elif event_name == "chest" or event_name == "lucky":
			tile.add_theme_stylebox_override("panel", _panel_style("#715d2c", "#f5d58a"))
			tile.scale = Vector2.ONE
		elif event_name == "heal":
			tile.add_theme_stylebox_override("panel", _panel_style("#235c48", "#7dffb0"))
			tile.scale = Vector2.ONE
		else:
			tile.add_theme_stylebox_override("panel", _panel_style("#34465b", "#66758a"))
			tile.scale = Vector2.ONE
	var info := find_child("StepInfo", true, false) as Label
	if info:
		info.text = "Stage %d • Trail: %d / %d" % [stage, step, maxi(1, spaces.size() - 1)]

func _set_status(message: String) -> void:
	status_label.text = message

func _set_hero_frame(frame: int, walking: bool = false) -> void:
	var path := (HERO_WALK % clampi(frame, 1, 8)) if walking else (HERO_IDLE % clampi(frame, 1, 8))
	if ResourceLoader.exists(path):
		hero.texture = load(path)

func _start_idle_animation() -> void:
	while is_instance_valid(hero):
		if not hero_animating:
			hero_idle_frame = (hero_idle_frame % 8) + 1
			_set_hero_frame(hero_idle_frame)
		await get_tree().create_timer(0.14).timeout

func _start_goblin_animation() -> void:
	var frame := 0
	while is_instance_valid(goblin):
		if not rolling and not awaiting_answer and ResourceLoader.exists(goblin_animation_paths[frame]):
			goblin.texture = load(goblin_animation_paths[frame])
			frame = (frame + 1) % goblin_animation_paths.size()
		await get_tree().create_timer(0.75).timeout

func _on_roll_pressed() -> void:
	if rolling or awaiting_answer:
		return
	if step >= spaces.size() - 1:
		_finish_quest()
		return
	rolling = true
	roll_button.disabled = true
	var original_scale := dice_label.scale
	for i in range(14):
		dice_label.text = "🎲  " + str(rng.randi_range(1, 6))
		dice_label.rotation = deg_to_rad(rng.randf_range(-10.0, 10.0))
		dice_label.scale = Vector2.ONE * rng.randf_range(0.9, 1.18)
		await get_tree().create_timer(0.065).timeout
	var roll := rng.randi_range(1, 6)
	dice_label.text = "🎲  " + str(roll)
	dice_label.rotation = 0.0
	var settle := create_tween()
	settle.tween_property(dice_label, "scale", Vector2(1.22, 1.22), 0.12)
	settle.tween_property(dice_label, "scale", original_scale, 0.15)
	var target := mini(step + roll, spaces.size() - 1)
	await _move_hero(target)
	step = target
	_update_board()
	rolling = false
	_land_on_tile()

func _land_on_tile() -> void:
	var event_name: String = tile_events[step] if step < tile_events.size() else "empty"
	match event_name:
		"fight":
			_show_monster_encounter(false)
		"boss":
			_show_boss_question()
		"heal":
			var heal_amount := 12 + stage * 4
			hero_hp = mini(hero_max_hp, hero_hp + heal_amount)
			_update_hero_stats()
			tile_events[step] = "empty"
			_update_board()
			_set_status("Healing spring! Restored %d HP." % heal_amount)
			roll_button.disabled = false
		"chest":
			_show_question("chest")
		"trap":
			var trap_damage := 7 + stage * 3
			hero_hp = maxi(1, hero_hp - trap_damage)
			win_streak = 0
			tile_events[step] = "empty"
			_update_hero_stats()
			_update_board()
			_set_status("Trap! Lost %d HP, but you survive." % trap_damage)
			roll_button.disabled = false
		"lucky":
			var bonus := rng.randi_range(0, 2)
			if bonus == 0:
				hero_attack += 1
			elif bonus == 1:
				hero_defense += 1
			else:
				hero_max_hp += 8
				hero_hp = mini(hero_max_hp, hero_hp + 8)
			tile_events[step] = "empty"
			_update_hero_stats()
			_update_board()
			_set_status("Lucky tile! " + ["ATK +1","DEF +1","Max HP +8"][bonus])
			roll_button.disabled = false
		"skip":
			tile_events[step] = "empty"
			_set_status("A wind boost! Moving 3 extra tiles.")
			roll_button.disabled = true
			await get_tree().create_timer(0.3).timeout
			var skip_target := mini(step + 3, spaces.size() - 1)
			await _move_hero(skip_target)
			step = skip_target
			_update_board()
			_land_on_tile()
		_:
			_set_status("The path is clear. Roll again!")
			roll_button.disabled = false

func _exp_needed() -> int:
	return hero_level * 20

func _record_answer(question: Dictionary, correct: bool) -> void:
	var subject := str(question.subject)
	questions_seen[subject] = int(questions_seen.get(subject, 0)) + 1
	if correct:
		questions_right[subject] = int(questions_right.get(subject, 0)) + 1
	else:
		missed_questions.append({"subject": subject, "question": question.q, "answer": question.answers[int(question.correct)]})

func _show_boss_question() -> void:
	var question: Dictionary = _get_question(true)
	awaiting_answer = true
	roll_button.disabled = true
	boss_shield_bonus = 0
	for child in answer_box.get_children():
		child.queue_free()
	question_timer_id += 1
	var this_timer := question_timer_id
	_set_status("BOSS SHIELD: answer correctly to break it!")
	var prompt := Label.new()
	prompt.text = "Stage %d Boss Shield\n%s: %s" % [stage, question.subject, question.q]
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	answer_box.add_child(prompt)
	var order: Array[int] = [0, 1, 2]
	order.shuffle()
	for answer_index in order:
		var answer_button := Button.new()
		answer_button.text = str(question.answers[answer_index])
		answer_button.pressed.connect(func():
			if not awaiting_answer or this_timer != question_timer_id:
				return
			awaiting_answer = false
			_record_answer(question, answer_index == int(question.correct))
			if answer_index == int(question.correct):
				win_streak += 1
				boss_shield_bonus = 0
				_set_status("Correct! The boss shield is broken.")
			else:
				win_streak = 0
				boss_shield_bonus = 4
				_set_status("Wrong! The boss gains extra defense. Answer: " + str(question.answers[int(question.correct)]))
			_clear_answer_box()
			_show_monster_encounter(true)
		)
		answer_box.add_child(answer_button)
	answer_box.visible = true
	if is_instance_valid(quiz_popup): quiz_popup.visible = true
	if is_instance_valid(quiz_popup): quiz_popup.visible = true
	if fifty_fifty_charges > 0:
		var helper := Button.new()
		helper.text = "50/50 (%d left)" % fifty_fifty_charges
		helper.pressed.connect(func():
			if not awaiting_answer or this_timer != question_timer_id:
				return
			var wrong_buttons: Array[Button] = []
			for child in answer_box.get_children():
				if child is Button and child.text != str(question.answers[int(question.correct)]) and child != helper:
					wrong_buttons.append(child)
			if wrong_buttons.size() > 0:
				wrong_buttons[rng.randi_range(0, wrong_buttons.size() - 1)].disabled = true
				fifty_fifty_charges -= 1
				helper.disabled = true
				_update_hero_stats()
		)
		answer_box.add_child(helper)

func _get_question(harder: bool = false) -> Dictionary:
	var allowed: Array[Dictionary] = []
	var target_difficulty := mini(3, 1 + int((stage - 1) / 2) + (1 if harder else 0))
	for question in QUESTIONS:
		if int(question.difficulty) <= target_difficulty:
			allowed.append(question)
	if allowed.is_empty():
		return QUESTIONS[rng.randi_range(0, QUESTIONS.size() - 1)]
	return allowed[rng.randi_range(0, allowed.size() - 1)]

func _clear_answer_box() -> void:
	if is_instance_valid(quiz_popup):
		quiz_popup.visible = false
	for child in answer_box.get_children():
		child.queue_free()
	answer_box.visible = false

func _move_hero(target: int) -> void:
	hero_animating = true
	for next_step in range(step + 1, target + 1):
		for frame in range(1, 9):
			_set_hero_frame(frame, true)
			await get_tree().create_timer(0.045).timeout
	_set_hero_frame(1)
	hero_animating = false

func _show_question(kind: String = "chest") -> void:
	awaiting_answer = true
	roll_button.disabled = true
	var question: Dictionary = _get_question(false)
	question_index += 1
	question_timer_id += 1
	var this_timer := question_timer_id
	_set_status("QUIZ CHEST: correct answers make your hero stronger!")
	_clear_answer_box()
	var prompt := Label.new()
	prompt.text = "%s • %s\n%s" % [question.subject, "Hard" if int(question.difficulty) >= 3 else "Question", question.q]
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	answer_box.add_child(prompt)
	var order: Array[int] = [0, 1, 2]
	order.shuffle()
	for answer_index in order:
		var answer_button := Button.new()
		answer_button.text = str(question.answers[answer_index])
		answer_button.pressed.connect(func():
			if not awaiting_answer or this_timer != question_timer_id:
				return
			awaiting_answer = false
			var is_correct := answer_index == int(question.correct)
			_record_answer(question, is_correct)
			_clear_answer_box()
			if is_correct:
				win_streak += 1
				experience += 8 + int(question.difficulty) * 4
				var bonus_text := ""
				if win_streak > 0 and win_streak % 3 == 0:
					hero_max_hp += 5
					hero_hp += 5
					bonus_text = " Streak bonus: Max HP +5!"
				var reward_kind := rng.randi_range(0, 3)
				match reward_kind:
					0:
						hero_attack += 1
						bonus_text += " ATK +1."
					1:
						hero_defense += 1
						bonus_text += " DEF +1."
					2:
						hero_hp = mini(hero_max_hp, hero_hp + 15)
						bonus_text += " Healed 15 HP."
					_:
						hero_max_hp += 5
						hero_hp += 5
						bonus_text += " Max HP +5."
				_set_status("Correct! You got stronger.%s" % bonus_text)
				_flash_feedback(Color("#7dffb0"))
				tile_events[step] = "empty"
				_update_hero_stats()
				_update_board()
				_check_level_up()
			else:
				win_streak = 0
				hero_hp = maxi(0, hero_hp - (5 + 5 * stage))
				_set_status("Wrong! Lost HP. Correct answer: %s" % str(question.answers[int(question.correct)]))
				_flash_feedback(Color("#ff8c8c"))
				tile_events[step] = "empty"
				_update_hero_stats()
				_update_board()
				roll_button.disabled = false
		)
		answer_box.add_child(answer_button)
	answer_box.visible = true
	if fifty_fifty_charges > 0:
		var helper := Button.new()
		helper.text = "50/50 (%d left)" % fifty_fifty_charges
		helper.pressed.connect(func():
			if not awaiting_answer or this_timer != question_timer_id:
				return
			var wrong_buttons: Array[Button] = []
			for child in answer_box.get_children():
				if child is Button and child != helper and child.text != str(question.answers[int(question.correct)]):
					wrong_buttons.append(child)
			if wrong_buttons.size() > 0:
				wrong_buttons[rng.randi_range(0, wrong_buttons.size() - 1)].disabled = true
				fifty_fifty_charges -= 1
				helper.disabled = true
				_update_hero_stats()
		)
		answer_box.add_child(helper)
	if int(question.difficulty) >= 3:
		var time_left := 15
		var timer_label := Label.new()
		timer_label.text = "Time left: 15s"
		answer_box.add_child(timer_label)
		while time_left > 0 and awaiting_answer and this_timer == question_timer_id:
			await get_tree().create_timer(1.0).timeout
			time_left -= 1
			if is_instance_valid(timer_label):
				timer_label.text = "Time left: %ds" % time_left
		if time_left <= 0 and awaiting_answer and this_timer == question_timer_id:
			awaiting_answer = false
			_record_answer(question, false)
			win_streak = 0
			hero_hp = maxi(1, hero_hp - (5 + stage * 2))
			_clear_answer_box()
			_update_hero_stats()
			_set_status("Time's up! Lost HP. Answer: %s" % str(question.answers[int(question.correct)]))
			roll_button.disabled = false

func _check_level_up() -> void:
	if experience < _exp_needed():
		roll_button.disabled = false
		return
	experience -= _exp_needed()
	hero_level += 1
	if hero_level % 3 == 0:
		fifty_fifty_charges += 1
	awaiting_answer = true
	roll_button.disabled = true
	_set_status("LEVEL UP! Answer a question to choose a reward.")
	var question: Dictionary = _get_question(true)
	_clear_answer_box()
	var prompt := Label.new()
	prompt.text = "Level %d: %s\n%s" % [hero_level, question.subject, question.q]
	prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	answer_box.add_child(prompt)
	var order: Array[int] = [0, 1, 2]
	order.shuffle()
	for answer_index in order:
		var b := Button.new()
		b.text = str(question.answers[answer_index])
		b.pressed.connect(func():
			if not awaiting_answer:
				return
			awaiting_answer = false
			var correct := answer_index == int(question.correct)
			_record_answer(question, correct)
			_clear_answer_box()
			if correct:
				win_streak += 1
				_show_level_rewards()
			else:
				win_streak = 0
				hero_hp = maxi(0, hero_hp - (5 + 5 * stage))
				_update_hero_stats()
				_set_status("Level-up answer wrong. You lose HP and get no reward.")
				roll_button.disabled = false
		)
		answer_box.add_child(b)
	answer_box.visible = true

func _show_level_rewards() -> void:
	awaiting_answer = true
	_set_status("Correct! Choose one of two rewards.")
	_clear_answer_box()
	var rewards: Array[Dictionary] = [
		{"name":"ATK +%d" % rng.randi_range(2, 5),"id":"atk","amount":0},{"name":"DEF +%d" % rng.randi_range(1, 3),"id":"def","amount":0},
		{"name":"Heal %d HP" % rng.randi_range(20, 40),"id":"heal","amount":0},{"name":"Max HP +%d%%" % rng.randi_range(10, 20),"id":"max","amount":0}
	]
	rewards.shuffle()
	for reward in rewards.slice(0, 2):
		var b := Button.new()
		b.text = str(reward.name)
		b.pressed.connect(func():
			match str(reward.id):
				"atk": hero_attack += int(str(reward.name).trim_prefix("ATK +"))
				"def": hero_defense += int(str(reward.name).trim_prefix("DEF +"))
				"heal": hero_hp = mini(hero_max_hp, hero_hp + int(str(reward.name).trim_prefix("Heal ").trim_suffix(" HP")))
				"max":
					var percent := int(str(reward.name).trim_prefix("Max HP +").trim_suffix("%"))
					var increase := int(ceil(float(hero_max_hp) * float(percent) / 100.0))
					hero_max_hp += increase
					hero_hp = mini(hero_max_hp, hero_hp + increase)
			awaiting_answer = false
			_clear_answer_box()
			_update_hero_stats()
			_set_status("Reward claimed! Keep going.")
			roll_button.disabled = false
		)
		answer_box.add_child(b)
	answer_box.visible = true

func _flash_feedback(tint: Color) -> void:
	var original := status_label.modulate
	var tween := create_tween()
	tween.tween_property(status_label, "modulate", tint, 0.12)
	tween.tween_property(status_label, "modulate", original, 0.45)

func _build_battle_overlay() -> void:
	battle_overlay = ColorRect.new()
	battle_overlay.color = Color(0.015, 0.02, 0.045, 0.88)
	battle_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	battle_overlay.visible = false
	battle_overlay.z_index = 50
	add_child(battle_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	battle_overlay.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 420)
	panel.add_theme_stylebox_override("panel", _panel_style("#111b2d", "#f5d58a"))
	center.add_child(panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 12)
	panel.add_child(col)
	battle_title = Label.new()
	battle_title.text = "MONSTER ENCOUNTER!"
	battle_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_title.add_theme_font_size_override("font_size", 28)
	battle_title.add_theme_color_override("font_color", Color("#f5d58a"))
	col.add_child(battle_title)
	var fighters := HBoxContainer.new()
	fighters.alignment = BoxContainer.ALIGNMENT_CENTER
	fighters.add_theme_constant_override("separation", 40)
	col.add_child(fighters)
	battle_hero = TextureRect.new()
	battle_hero.custom_minimum_size = Vector2(180, 180)
	battle_hero.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	battle_hero.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	battle_hero.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fighters.add_child(battle_hero)
	battle_monster = TextureRect.new()
	battle_monster.custom_minimum_size = Vector2(180, 180)
	battle_monster.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	battle_monster.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	battle_monster.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	fighters.add_child(battle_monster)
	battle_log = Label.new()
	battle_log.text = "The hero and goblin face each other!"
	battle_log.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(battle_log)
	battle_stats_label = Label.new()
	battle_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	battle_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	battle_stats_label.add_theme_color_override("font_color", Color("#e2e8f0"))
	col.add_child(battle_stats_label)

func _show_monster_encounter(is_boss: bool = false) -> void:
	awaiting_answer = true
	roll_button.disabled = true
	current_battle_is_boss = is_boss
	battle_overlay.visible = true
	battle_hero.texture = load(HERO_IDLE % 1) if ResourceLoader.exists(HERO_IDLE % 1) else hero.texture
	battle_monster.texture = load(GOBLIN_IDLE) if ResourceLoader.exists(GOBLIN_IDLE) else goblin.texture
	battle_hero.scale = Vector2.ONE
	battle_monster.scale = Vector2.ONE
	battle_hero.modulate = Color.WHITE
	battle_monster.modulate = Color.WHITE
	var monster_names := ["Goblin", "Bat", "Skeleton", "Slime", "Wolf"]
	var boss_names := ["Slime King", "Stone Golem", "Shadow Witch", "Dragon Lord", "Ancient Titan"]
	var monster_name: String = (str(boss_names[mini(stage - 1, 4)]) if not endless_mode else "Endless Boss %d" % stage) if is_boss else str(monster_names[rng.randi_range(0, monster_names.size() - 1)])
	goblin_max_hp = (100 + stage * 28) if is_boss else (18 + stage * 7)
	goblin_hp = goblin_max_hp
	goblin_attack = (8 + stage * 3) if is_boss else (3 + stage * 2)
	goblin_defense = (2 + stage * 2 + boss_shield_bonus) if is_boss else maxi(0, stage - 1)
	battle_title.text = ("STAGE %d • %s" % [stage, monster_name]) if is_boss else monster_name.to_upper() + " BATTLE"
	battle_log.text = "A powerful enemy blocks your path!"
	_update_battle_stats()
	await get_tree().create_timer(0.5).timeout
	var round_index := 1
	while hero_hp > 0 and goblin_hp > 0:
		battle_log.text = "Round %d: Your hero attacks!" % round_index
		var hero_damage: int = maxi(1, hero_attack - goblin_defense + rng.randi_range(-1, 1))
		goblin_hp = maxi(0, goblin_hp - hero_damage)
		_update_battle_stats()
		var hero_start := battle_hero.position
		var dash := create_tween()
		dash.tween_property(battle_hero, "position:x", hero_start.x + 28, 0.14)
		dash.tween_property(battle_hero, "position:x", hero_start.x, 0.14)
		dash.parallel().tween_property(battle_monster, "modulate", Color("#ff7777"), 0.12)
		dash.tween_property(battle_monster, "modulate", Color.WHITE, 0.16)
		await dash.finished
		battle_log.text = "You dealt %d damage." % hero_damage
		await get_tree().create_timer(0.25).timeout
		if goblin_hp <= 0:
			break
		var enemy_damage: int = maxi(1, goblin_attack - hero_defense + rng.randi_range(-1, 1))
		hero_hp = maxi(0, hero_hp - enemy_damage)
		_update_hero_stats()
		_update_battle_stats()
		battle_log.text = "Enemy dealt %d damage." % enemy_damage
		var hit_tween := create_tween()
		hit_tween.tween_property(battle_hero, "modulate", Color("#ffb0a5"), 0.12)
		hit_tween.tween_property(battle_hero, "modulate", Color.WHITE, 0.16)
		await hit_tween.finished
		await get_tree().create_timer(0.3).timeout
		round_index += 1
	if goblin_hp <= 0:
		battle_title.text = "VICTORY!"
		battle_log.text = "You defeated the enemy!"
		var victory := create_tween()
		victory.tween_property(battle_monster, "scale", Vector2(0.1, 0.1), 0.3)
		victory.parallel().tween_property(battle_monster, "modulate:a", 0.0, 0.3)
		await victory.finished
	else:
		battle_title.text = "DEFEATED"
		battle_log.text = "Your stage run has ended."
	await get_tree().create_timer(0.7).timeout
	battle_overlay.visible = false
	battle_monster.scale = Vector2.ONE
	battle_monster.modulate = Color.WHITE
	battle_monster.position = Vector2.ZERO
	battle_hero.modulate = Color.WHITE
	awaiting_answer = false
	if goblin_hp <= 0:
		if is_boss:
			_on_boss_defeated()
		else:
			experience += 20
			tile_events[step] = "empty"
			_update_board()
			_update_hero_stats()
			_set_status("Monster defeated! +20 EXP.")
			roll_button.disabled = false
			_check_level_up()
	else:
		_show_retry_screen()

func _show_retry_screen() -> void:
	roll_button.disabled = true
	awaiting_answer = true
	_clear_answer_box()
	var label := Label.new()
	label.text = "You were defeated in Stage %d. Retry with your stats from the start of this stage?" % stage
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	answer_box.add_child(label)
	var retry_button := Button.new()
	retry_button.text = "Retry Stage"
	retry_button.pressed.connect(func():
		hero_hp = int(stage_snapshot.hp)
		hero_max_hp = int(stage_snapshot.max_hp)
		hero_attack = int(stage_snapshot.attack)
		hero_defense = int(stage_snapshot.defense)
		hero_level = int(stage_snapshot.level)
		experience = int(stage_snapshot.exp)
		fifty_fifty_charges = int(stage_snapshot.helper)
		win_streak = int(stage_snapshot.streak)
		_clear_answer_box()
		awaiting_answer = false
		_start_stage(false)
		_update_board()
		_update_hero_stats()
		_set_status("Stage %d restarted. Your starting stats are restored." % stage)
		roll_button.disabled = false
	)
	answer_box.add_child(retry_button)
	answer_box.visible = true

func _on_boss_defeated() -> void:
	if stage >= stage_count and not endless_mode:
		_show_study_summary(true)
		return
	stage += 1
	hero_hp = hero_max_hp
	experience = 0
	hero_max_hp += int(ceil(float(hero_max_hp) * rng.randf_range(0.10, 0.20)))
	hero_hp = hero_max_hp
	_start_stage(false)
	_update_board()
	_update_hero_stats()
	_set_status("Boss defeated! Stage %d begins. HP restored and Max HP increased." % stage)
	roll_button.disabled = false

func _show_study_summary(won: bool) -> void:
	awaiting_answer = true
	roll_button.disabled = true
	_clear_answer_box()
	var summary := Label.new()
	summary.text = "QUEST COMPLETE! You defeated every boss.\nSTUDY SUMMARY"
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	answer_box.add_child(summary)
	for subject in ["Science", "Math", "English", "World", "Tech"]:
		var line := Label.new()
		line.text = "%s: %d/%d correct" % [subject, int(questions_right.get(subject, 0)), int(questions_seen.get(subject, 0))]
		answer_box.add_child(line)
	for miss in missed_questions:
		var line := Label.new()
		line.text = "Missed (%s): %s → %s" % [miss.subject, miss.question, miss.answer]
		line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		answer_box.add_child(line)
	var endless_button := Button.new()
	endless_button.text = "Endless Mode"
	endless_button.pressed.connect(func():
		endless_mode = true
		stage += 1
		hero_hp = hero_max_hp
		experience = 0
		_start_stage(false)
		_clear_answer_box()
		awaiting_answer = false
		_update_board()
		_update_hero_stats()
		_set_status("Endless Mode! Stage %d." % stage)
		roll_button.disabled = false
	)
	answer_box.add_child(endless_button)
	var menu_button := Button.new()
	menu_button.text = "Main Menu"
	menu_button.pressed.connect(func(): get_tree().change_scene_to_file("res://main_menu.tscn"))
	answer_box.add_child(menu_button)
	answer_box.visible = true

func _update_hero_stats() -> void:
	if is_instance_valid(hp_bar):
		hp_bar.max_value = maxi(1, hero_max_hp)
		hp_bar.value = clampi(hero_hp, 0, hero_max_hp)
		hp_bar.tooltip_text = "HP: %d / %d" % [hero_hp, hero_max_hp]
	if is_instance_valid(exp_bar):
		exp_bar.max_value = maxi(1, _exp_needed())
		exp_bar.value = clampi(experience, 0, _exp_needed())
		exp_bar.tooltip_text = "EXP: %d / %d" % [experience, _exp_needed()]
	if is_instance_valid(hero_stats_label):
		hero_stats_label.text = "HP %d/%d   ATK %d   DEF %d\nLV %d   EXP %d/%d   Streak %d   50/50: %d" % [hero_hp, hero_max_hp, hero_attack, hero_defense, hero_level, experience, _exp_needed(), win_streak, fifty_fifty_charges]

func _update_battle_stats() -> void:
	if is_instance_valid(battle_stats_label):
		battle_stats_label.text = "HERO  HP %d/%d  | ATK %d  | DEF %d\nGOBLIN  HP %d/%d  | ATK %d  | DEF %d" % [hero_hp, hero_max_hp, hero_attack, hero_defense, goblin_hp, goblin_max_hp, goblin_attack, goblin_defense]

func _finish_quest() -> void:
	if step >= spaces.size() - 1:
		_show_boss_question()
	else:
		roll_button.disabled = false
