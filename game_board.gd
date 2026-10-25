extends Control

const HERO_IDLE := "res://hero_pack/hero/frames/idle/hero_idle_%02d.png"
const HERO_WALK := "res://hero_pack/hero/frames/walk/hero_walk_%02d.png"
const GOBLIN_IDLE := "res://Godot_Monster_Assets/monsters/goblin/frames/goblin_idle.png"
const QUESTIONS := [
	{"q":"Which command retrieves data from a database?","answers":["SELECT","DELETE","DROP"],"correct":0},
	{"q":"Which part of a computer runs program instructions?","answers":["Monitor","CPU","Keyboard"],"correct":1},
	{"q":"What does HTML mainly structure?","answers":["Web pages","Databases","Networks"],"correct":0},
	{"q":"Which one is an input device?","answers":["Speaker","Monitor","Keyboard"],"correct":2},
	{"q":"Which symbol commonly ends a SQL statement?","answers":[";","?","@"],"correct":0}
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
var path_grid: GridContainer
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
var hero_max_hp := 100
var hero_hp := 100
var hero_attack := 18
var hero_defense := 6
var goblin_max_hp := 48
var goblin_hp := 48
var goblin_attack := 12
var goblin_defense := 3

func _ready() -> void:
	rng.randomize()
	_build_ui()
	_update_board()
	_set_status("Your quest begins! Roll the dice to travel toward the dungeon.")
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
	path_grid = GridContainer.new()
	path_grid.columns = 6
	path_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	path_grid.add_theme_constant_override("h_separation", 8)
	path_grid.add_theme_constant_override("v_separation", 8)
	board_col.add_child(path_grid)
	for i in range(24):
		var tile := PanelContainer.new()
		tile.custom_minimum_size = Vector2(78, 72)
		tile.add_theme_stylebox_override("panel", _panel_style("#34465b", "#66758a"))
		var tile_content := VBoxContainer.new()
		tile_content.add_theme_constant_override("separation", 0)
		tile_content.alignment = BoxContainer.ALIGNMENT_CENTER
		tile.add_child(tile_content)
		var icon := TextureRect.new()
		icon.name = "TileIcon"
		icon.custom_minimum_size = Vector2(30, 30)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tile_content.add_child(icon)
		var label := Label.new()
		label.name = "TileLabel"
		label.text = str(i + 1)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 13)
		tile_content.add_child(label)
		path_grid.add_child(tile)
		spaces.append(tile)
	var hint := Label.new()
	hint.text = "Icons: start, quiz scrolls, goblins, treasure, potions, and the final boss"
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
	hero_stats_label = Label.new()
	hero_stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_stats_label.add_theme_color_override("font_color", Color("#e2e8f0"))
	side_col.add_child(hero_stats_label)
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
	answer_box = VBoxContainer.new()
	answer_box.add_theme_constant_override("separation", 6)
	side_col.add_child(answer_box)
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

func _update_board() -> void:
	for i in range(spaces.size()):
		var tile := spaces[i]
		var content := tile.get_child(0) as VBoxContainer
		var icon := content.get_node("TileIcon") as TextureRect
		var label := content.get_node("TileLabel") as Label
		var icon_name := "empty"
		if i == 0:
			icon_name = "start"
		elif i == 23:
			icon_name = "boss"
		elif i % 5 == 3:
			icon_name = "goblin"
		elif i % 4 == 2:
			icon_name = "scroll"
		elif i % 7 == 5:
			icon_name = "chest"
		elif i % 6 == 4:
			icon_name = "potion"
		var icon_path := "res://Dungeon_Tiles_and_Dice/tiles/128/%s.png" % icon_name
		if ResourceLoader.exists(icon_path):
			icon.texture = load(icon_path)
		else:
			icon.texture = null
		label.text = "YOU" if i == step else str(i + 1)
		label.add_theme_color_override("font_color", Color.WHITE if i == step else Color("#e2e8f0"))
		if i == step:
			tile.add_theme_stylebox_override("panel", _panel_style("#2878b8", "#ffffff"))
			tile.scale = Vector2(1.06, 1.06)
		elif i % 5 == 3:
			tile.add_theme_stylebox_override("panel", _panel_style("#713c42", "#dc8b7f"))
			tile.scale = Vector2.ONE
		elif i % 4 == 2:
			tile.add_theme_stylebox_override("panel", _panel_style("#715d2c", "#f5d58a"))
			tile.scale = Vector2.ONE
		else:
			tile.add_theme_stylebox_override("panel", _panel_style("#34465b", "#66758a"))
			tile.scale = Vector2.ONE
	var info := find_child("StepInfo", true, false) as Label
	if info:
		info.text = "Trail progress: %d / 24" % step

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
	if step >= 23:
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
	var target := mini(step + roll, 23)
	await _move_hero(target)
	step = target
	_update_board()
	rolling = false
	if step >= 23:
		_set_status("You reached the dungeon gate! Roll again to complete the rescue.")
		roll_button.text = "COMPLETE QUEST"
		roll_button.disabled = false
	elif step % 5 == 3:
		_show_monster_encounter()
	elif step % 4 == 2:
		_show_question()
	else:
		_set_status("The path is clear. Keep moving toward the dungeon!")
		roll_button.disabled = false

func _move_hero(target: int) -> void:
	hero_animating = true
	for next_step in range(step + 1, target + 1):
		for frame in range(1, 9):
			_set_hero_frame(frame, true)
			await get_tree().create_timer(0.045).timeout
	_set_hero_frame(1)
	hero_animating = false

func _show_question() -> void:
	awaiting_answer = true
	roll_button.disabled = true
	var question: Dictionary = QUESTIONS[question_index % QUESTIONS.size()]
	question_index += 1
	_set_status("QUIZ CHALLENGE: " + str(question.q))
	for child in answer_box.get_children():
		child.queue_free()
	for i in range(question.answers.size()):
		var answer := Button.new()
		answer.text = str(question.answers[i])
		answer.pressed.connect(_on_answer_selected.bind(i, int(question.correct)))
		answer_box.add_child(answer)
	answer_box.visible = true

func _on_answer_selected(selected: int, correct: int) -> void:
	if not awaiting_answer:
		return
	awaiting_answer = false
	for child in answer_box.get_children():
		child.queue_free()
	if selected == correct:
		_set_status("Correct! You earned a rescue star. Roll to continue.")
		_flash_feedback(Color("#7dffb0"))
	else:
		_set_status("Not quite! The goblin gets closer. Try the next challenge.")
		_flash_feedback(Color("#ff8c8c"))
	roll_button.disabled = false

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

func _show_monster_encounter() -> void:
	awaiting_answer = true
	roll_button.disabled = true
	battle_overlay.visible = true
	battle_hero.texture = load(HERO_IDLE % 1) if ResourceLoader.exists(HERO_IDLE % 1) else hero.texture
	battle_monster.texture = load(GOBLIN_IDLE) if ResourceLoader.exists(GOBLIN_IDLE) else goblin.texture
	battle_hero.scale = Vector2.ONE
	battle_monster.scale = Vector2.ONE
	battle_hero.modulate = Color.WHITE
	battle_monster.modulate = Color.WHITE
	goblin_hp = goblin_max_hp
	battle_title.text = "GOBLIN BATTLE — TILE %d" % (step + 1)
	battle_log.text = "A goblin blocks your path!"
	_update_battle_stats()
	await get_tree().create_timer(0.6).timeout
	var round_index := 1
	while hero_hp > 0 and goblin_hp > 0:
		battle_log.text = "Round %d: The hero attacks!" % round_index
		var hero_damage: int = maxi(1, hero_attack + rng.randi_range(-3, 4) - goblin_defense)
		goblin_hp = maxi(0, goblin_hp - hero_damage)
		_update_battle_stats()
		var hero_start := battle_hero.position
		var dash := create_tween()
		dash.tween_property(battle_hero, "position:x", hero_start.x + 34, 0.14)
		dash.tween_property(battle_hero, "position:x", hero_start.x, 0.14)
		dash.parallel().tween_property(battle_monster, "modulate", Color("#ff7777"), 0.12)
		dash.tween_property(battle_monster, "modulate", Color.WHITE, 0.16)
		dash.parallel().tween_property(battle_monster, "scale", Vector2(0.88, 0.88), 0.12)
		dash.tween_property(battle_monster, "scale", Vector2.ONE, 0.16)
		await dash.finished
		battle_log.text = "Hero deals %d damage!" % hero_damage
		await get_tree().create_timer(0.35).timeout
		if goblin_hp <= 0:
			break
		battle_log.text = "The goblin strikes back!"
		var goblin_damage: int = maxi(1, goblin_attack + rng.randi_range(-2, 3) - hero_defense)
		hero_hp = maxi(0, hero_hp - goblin_damage)
		_update_hero_stats()
		_update_battle_stats()
		var monster_tween := create_tween()
		monster_tween.tween_property(battle_monster, "position:x", battle_monster.position.x - 26, 0.12)
		monster_tween.tween_property(battle_monster, "position:x", battle_monster.position.x, 0.12)
		monster_tween.parallel().tween_property(battle_hero, "modulate", Color("#ffb0a5"), 0.12)
		monster_tween.tween_property(battle_hero, "modulate", Color.WHITE, 0.16)
		await monster_tween.finished
		battle_log.text = "Goblin deals %d damage!" % goblin_damage
		await get_tree().create_timer(0.45).timeout
		round_index += 1
	if goblin_hp <= 0:
		battle_title.text = "GOBLIN DEFEATED!"
		battle_log.text = "Victory! The path is clear."
		var victory := create_tween()
		victory.tween_property(battle_monster, "scale", Vector2(0.1, 0.1), 0.35)
		victory.parallel().tween_property(battle_monster, "modulate:a", 0.0, 0.35)
		await victory.finished
	else:
		battle_title.text = "HERO NEEDS TO RECOVER"
		battle_log.text = "You were overwhelmed! You recover with half HP and can try again."
		hero_hp = maxi(1, int(ceil(hero_max_hp * 0.5)))
		_update_hero_stats()
	await get_tree().create_timer(1.0).timeout
	battle_overlay.visible = false
	battle_monster.scale = Vector2.ONE
	battle_monster.modulate = Color.WHITE
	battle_monster.position = Vector2.ZERO
	battle_hero.modulate = Color.WHITE
	awaiting_answer = false
	roll_button.disabled = false
	if goblin_hp <= 0:
		_set_status("Victory on tile %d! Roll again to continue." % (step + 1))
	else:
		_set_status("Recovering after the battle. Your HP is restored to %d." % hero_hp)

func _update_hero_stats() -> void:
	if is_instance_valid(hero_stats_label):
		hero_stats_label.text = "HP %d/%d   ATK %d   DEF %d" % [hero_hp, hero_max_hp, hero_attack, hero_defense]

func _update_battle_stats() -> void:
	if is_instance_valid(battle_stats_label):
		battle_stats_label.text = "HERO  HP %d/%d  | ATK %d  | DEF %d\nGOBLIN  HP %d/%d  | ATK %d  | DEF %d" % [hero_hp, hero_max_hp, hero_attack, hero_defense, goblin_hp, goblin_max_hp, goblin_attack, goblin_defense]

func _finish_quest() -> void:
	roll_button.disabled = true
	_set_status("QUEST COMPLETE! You reached the dungeon and rescued the princess! 🎉")
	roll_button.text = "QUEST COMPLETE"
	var tween := create_tween()
	tween.tween_property(hero, "scale", Vector2(1.18, 1.18), 0.25)
	tween.tween_property(hero, "scale", Vector2.ONE, 0.25)
