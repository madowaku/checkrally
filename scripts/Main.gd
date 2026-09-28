extends Control

const COLS: int = 5
const ROWS: int = 3
const CELL: int = 72
const COURT_LEFT: int = 56
const COURT_TOP: int = 170
const SHOTS: Array[String] = ["Drop", "Lob", "Cross", "Drive"]

const COLOR_BG: Color = Color(0.035, 0.055, 0.070)
const COLOR_COURT: Color = Color(0.105, 0.255, 0.205)
const COLOR_REACH: Color = Color(0.180, 0.460, 0.430)
const COLOR_LEGAL_SAFE: Color = Color(0.530, 0.500, 0.230)
const COLOR_WIN_TARGET: Color = Color(0.950, 0.690, 0.180)
const COLOR_OPPONENT: Color = Color(0.780, 0.220, 0.220)
const COLOR_TEXT_SOFT: Color = Color(0.760, 0.840, 0.880)

var stages: Array = []
var stage_index: int = 0
var opponent: Dictionary = {"x": 2, "y": 1, "stance": "Neutral", "pressure": 0}
var selected_shot: String = ""
var legal_targets: Array = []
var shot_count: int = 0
var game_over: bool = false
var log_lines: Array[String] = []

var cell_buttons: Array = []
var shot_buttons: Dictionary = {}
var stage_buttons: Array = []

var stage_label: Label
var state_label: Label
var instruction_label: Label
var hint_label: Label
var lesson_label: Label
var reach_label: Label
var log_label: Label
var selection_label: Label
var result_panel: Panel
var result_label: Label
var next_button: Button
var retry_button: Button

func _ready() -> void:
	load_stages()
	build_ui()
	load_stage(0)

func load_stages() -> void:
	var file: FileAccess = FileAccess.open("res://data/stages.json", FileAccess.READ)
	if file == null:
		push_error("Could not open res://data/stages.json")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_ARRAY:
		push_error("stages.json must contain an array")
		return
	stages = parsed as Array

func build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = COLOR_BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title: Label = Label.new()
	title.text = "CHECKRALLY"
	title.position = Vector2(56, 24)
	title.size = Vector2(520, 42)
	title.add_theme_font_size_override("font_size", 34)
	add_child(title)

	var tagline: Label = Label.new()
	tagline.text = "Think ahead. Break their reach. Checkmate the rally."
	tagline.position = Vector2(58, 66)
	tagline.size = Vector2(720, 28)
	tagline.add_theme_font_size_override("font_size", 16)
	tagline.modulate = COLOR_TEXT_SOFT
	add_child(tagline)

	stage_label = Label.new()
	stage_label.position = Vector2(56, 112)
	stage_label.size = Vector2(640, 32)
	stage_label.add_theme_font_size_override("font_size", 19)
	add_child(stage_label)

	state_label = Label.new()
	state_label.position = Vector2(56, 140)
	state_label.size = Vector2(660, 26)
	state_label.add_theme_font_size_override("font_size", 14)
	state_label.modulate = Color(0.800, 0.920, 1.000)
	add_child(state_label)

	var court_title: Label = Label.new()
	court_title.text = "OPPONENT COURT"
	court_title.position = Vector2(COURT_LEFT, COURT_TOP - 30)
	court_title.size = Vector2(300, 24)
	court_title.modulate = Color(0.760, 0.940, 0.850)
	add_child(court_title)

	cell_buttons = []
	for y in range(ROWS):
		for x in range(COLS):
			var cell: Button = Button.new()
			cell.position = Vector2(COURT_LEFT + x * CELL, COURT_TOP + y * CELL)
			cell.size = Vector2(CELL - 4, CELL - 4)
			cell.text = ""
			cell.add_theme_font_size_override("font_size", 19)
			cell.pressed.connect(Callable(self, "on_cell_pressed").bind(x, y))
			add_child(cell)
			cell_buttons.append(cell)

	var baseline: ColorRect = ColorRect.new()
	baseline.position = Vector2(COURT_LEFT - 4, COURT_TOP + ROWS * CELL + 4)
	baseline.size = Vector2(COLS * CELL, 4)
	baseline.color = Color(0.820, 0.850, 0.840)
	add_child(baseline)

	selection_label = Label.new()
	selection_label.position = Vector2(56, 408)
	selection_label.size = Vector2(640, 48)
	selection_label.add_theme_font_size_override("font_size", 15)
	selection_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(selection_label)

	var shot_title: Label = Label.new()
	shot_title.text = "CHOOSE A SHOT"
	shot_title.position = Vector2(56, 464)
	shot_title.size = Vector2(240, 24)
	shot_title.modulate = COLOR_TEXT_SOFT
	add_child(shot_title)

	var shot_x: int = 56
	for shot_name in SHOTS:
		var shot: String = shot_name
		var b: Button = Button.new()
		b.text = shot
		b.position = Vector2(shot_x, 494)
		b.size = Vector2(112, 44)
		b.add_theme_font_size_override("font_size", 16)
		b.pressed.connect(Callable(self, "select_shot").bind(shot))
		add_child(b)
		shot_buttons[shot] = b
		shot_x += 122

	var reset: Button = Button.new()
	reset.text = "Retry"
	reset.position = Vector2(56, 554)
	reset.size = Vector2(112, 40)
	reset.pressed.connect(Callable(self, "reset_stage"))
	add_child(reset)

	var prev: Button = Button.new()
	prev.text = "< Puzzle"
	prev.position = Vector2(178, 554)
	prev.size = Vector2(112, 40)
	prev.pressed.connect(Callable(self, "prev_stage"))
	add_child(prev)

	var next: Button = Button.new()
	next.text = "Puzzle >"
	next.position = Vector2(300, 554)
	next.size = Vector2(112, 40)
	next.pressed.connect(Callable(self, "next_stage"))
	add_child(next)

	var right_x: int = 460
	var right_w: int = 580

	var rule_title: Label = Label.new()
	rule_title.text = "READ THE COURT"
	rule_title.position = Vector2(right_x, 118)
	rule_title.size = Vector2(right_w, 28)
	rule_title.add_theme_font_size_override("font_size", 18)
	add_child(rule_title)

	reach_label = Label.new()
	reach_label.position = Vector2(right_x, 150)
	reach_label.size = Vector2(right_w, 68)
	reach_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reach_label.add_theme_font_size_override("font_size", 14)
	add_child(reach_label)

	instruction_label = Label.new()
	instruction_label.position = Vector2(right_x, 224)
	instruction_label.size = Vector2(right_w, 70)
	instruction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction_label.add_theme_font_size_override("font_size", 15)
	instruction_label.modulate = Color(0.930, 0.840, 0.550)
	add_child(instruction_label)

	var hint_title: Label = Label.new()
	hint_title.text = "HINT"
	hint_title.position = Vector2(right_x, 302)
	hint_title.size = Vector2(100, 24)
	hint_title.modulate = COLOR_TEXT_SOFT
	add_child(hint_title)

	hint_label = Label.new()
	hint_label.position = Vector2(right_x, 328)
	hint_label.size = Vector2(right_w, 64)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.add_theme_font_size_override("font_size", 14)
	add_child(hint_label)

	lesson_label = Label.new()
	lesson_label.position = Vector2(right_x, 398)
	lesson_label.size = Vector2(right_w, 64)
	lesson_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lesson_label.add_theme_font_size_override("font_size", 14)
	lesson_label.modulate = Color(0.760, 0.950, 0.820)
	add_child(lesson_label)

	var log_title: Label = Label.new()
	log_title.text = "RALLY LOG"
	log_title.position = Vector2(right_x, 474)
	log_title.size = Vector2(140, 24)
	log_title.modulate = COLOR_TEXT_SOFT
	add_child(log_title)

	log_label = Label.new()
	log_label.position = Vector2(right_x, 500)
	log_label.size = Vector2(right_w, 106)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_font_size_override("font_size", 13)
	add_child(log_label)

	var legend: Label = Label.new()
	legend.text = "Teal = Reach   Pale gold = safe landing   Gold = winning Weak Zone"
	legend.position = Vector2(right_x, 614)
	legend.size = Vector2(right_w, 24)
	legend.add_theme_font_size_override("font_size", 12)
	legend.modulate = COLOR_TEXT_SOFT
	add_child(legend)

	var stage_title: Label = Label.new()
	stage_title.text = "PUZZLES"
	stage_title.position = Vector2(56, 624)
	stage_title.size = Vector2(100, 22)
	stage_title.modulate = COLOR_TEXT_SOFT
	add_child(stage_title)

	stage_buttons = []
	for i in range(10):
		var sb: Button = Button.new()
		sb.text = str(i + 1)
		sb.position = Vector2(56 + i * 48, 650)
		sb.size = Vector2(42, 34)
		sb.pressed.connect(Callable(self, "jump_stage").bind(i))
		add_child(sb)
		stage_buttons.append(sb)

	result_panel = Panel.new()
	result_panel.position = Vector2(448, 214)
	result_panel.size = Vector2(604, 260)
	result_panel.visible = false
	add_child(result_panel)

	result_label = Label.new()
	result_label.position = Vector2(24, 22)
	result_label.size = Vector2(556, 148)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.add_theme_font_size_override("font_size", 21)
	result_panel.add_child(result_label)

	retry_button = Button.new()
	retry_button.text = "Retry"
	retry_button.position = Vector2(70, 188)
	retry_button.size = Vector2(180, 46)
	retry_button.pressed.connect(Callable(self, "reset_stage"))
	result_panel.add_child(retry_button)

	next_button = Button.new()
	next_button.text = "Next Puzzle >>"
	next_button.position = Vector2(350, 188)
	next_button.size = Vector2(180, 46)
	next_button.pressed.connect(Callable(self, "next_stage"))
	result_panel.add_child(next_button)

func load_stage(index: int) -> void:
	if stages.is_empty():
		return
	stage_index = clampi(index, 0, stages.size() - 1)
	var stage: Dictionary = stages[stage_index]
	opponent = duplicate_dict(stage.get("opponent", {}))
	if not opponent.has("pressure"):
		opponent["pressure"] = 0
	selected_shot = ""
	legal_targets = []
	shot_count = 0
	game_over = false
	log_lines = []
	result_panel.visible = false
	lesson_label.text = ""
	update_all()

func duplicate_dict(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key in source.keys():
		result[key] = source[key]
	return result

func update_all() -> void:
	update_labels()
	update_shot_buttons()
	update_stage_buttons()
	redraw_court()
	update_log()

func update_labels() -> void:
	if stages.is_empty():
		return
	var stage: Dictionary = stages[stage_index]
	stage_label.text = "Puzzle %02d / %02d  %s   |   Score within %d shot(s)" % [
		int(stage.get("id", stage_index + 1)), stages.size(), str(stage.get("name", "")), int(stage.get("max_shots", 1))
	]
	state_label.text = "Opponent: (%d,%d)  %s%s   |   Shots: %d / %d" % [
		int(opponent.get("x", 2)), int(opponent.get("y", 1)), str(opponent.get("stance", "Neutral")),
		" + PRESSURED" if int(opponent.get("pressure", 0)) > 0 else "",
		shot_count, int(stage.get("max_shots", 1))
	]
	hint_label.text = str(stage.get("hint", ""))
	var reach_cells: Array = compute_reach_cells()
	reach_label.text = stance_explanation(str(opponent.get("stance", "Neutral")), int(opponent.get("pressure", 0))) + "\nCurrent Reach: %d / %d court cells." % [reach_cells.size(), COLS * ROWS]
	if selected_shot == "":
		instruction_label.text = "1. Choose a shot.  2. Legal landing squares light up.  3. Land outside teal Reach to score."
		selection_label.text = "Each shot reshapes the defender if they reach it. Build the weakness before taking the winner."
	else:
		instruction_label.text = selected_shot + " selected. Click a highlighted landing square. Gold wins now; pale gold is reached but changes the next position."
		selection_label.text = shot_explanation(selected_shot)

func update_shot_buttons() -> void:
	if stages.is_empty():
		return
	var stage: Dictionary = stages[stage_index]
	var available: Array = stage.get("available_shots", SHOTS)
	for shot_name in SHOTS:
		var shot: String = shot_name
		var button: Button = shot_buttons[shot]
		button.disabled = game_over or not array_has_string(available, shot)
		if selected_shot == shot:
			button.text = "[ " + shot + " ]"
		else:
			button.text = shot

func update_stage_buttons() -> void:
	for i in range(stage_buttons.size()):
		var button: Button = stage_buttons[i]
		button.disabled = i >= stages.size()
		button.text = "[" + str(i + 1) + "]" if i == stage_index else str(i + 1)

func redraw_court() -> void:
	var reach_cells: Array = compute_reach_cells()
	for y in range(ROWS):
		for x in range(COLS):
			var index: int = y * COLS + x
			var cell: Button = cell_buttons[index]
			var color: Color = COLOR_COURT
			var reachable: bool = contains_cell(reach_cells, x, y)
			var legal: bool = contains_cell(legal_targets, x, y)
			if reachable:
				color = COLOR_REACH
			if legal and reachable:
				color = COLOR_LEGAL_SAFE
			elif legal and not reachable:
				color = COLOR_WIN_TARGET
			if int(opponent.get("x", 2)) == x and int(opponent.get("y", 1)) == y:
				cell.text = "O"
				cell.add_theme_color_override("font_color", Color(1.0, 0.82, 0.82))
				color = color.lerp(COLOR_OPPONENT, 0.45)
			else:
				cell.text = ""
			cell.self_modulate = color

func select_shot(shot: String) -> void:
	if game_over:
		return
	var stage: Dictionary = stages[stage_index]
	var available: Array = stage.get("available_shots", SHOTS)
	if not array_has_string(available, shot):
		return
	selected_shot = shot
	legal_targets = compute_legal_targets(shot)
	update_all()

func on_cell_pressed(x: int, y: int) -> void:
	if game_over or selected_shot == "":
		return
	if not contains_cell(legal_targets, x, y):
		return
	resolve_shot(selected_shot, x, y)

func resolve_shot(shot: String, target_x: int, target_y: int) -> void:
	var reach_before: Array = compute_reach_cells()
	var can_reach: bool = contains_cell(reach_before, target_x, target_y)
	shot_count += 1
	if not can_reach:
		log_lines.push_front("%d. %s to (%d,%d): OUTSIDE REACH -> POINT" % [shot_count, shot, target_x, target_y])
		clear_puzzle(shot, target_x, target_y)
		return

	var old_stance: String = str(opponent.get("stance", "Neutral"))
	opponent["x"] = target_x
	opponent["y"] = target_y
	apply_shot_effect(shot, target_x)
	var new_stance: String = str(opponent.get("stance", "Neutral"))
	var pressure_text: String = " + PRESSURED" if int(opponent.get("pressure", 0)) > 0 else ""
	log_lines.push_front("%d. %s to (%d,%d): reached. %s -> %s%s" % [shot_count, shot, target_x, target_y, old_stance, new_stance, pressure_text])
	trim_log()

	selected_shot = ""
	legal_targets = []
	var stage: Dictionary = stages[stage_index]
	if shot_count >= int(stage.get("max_shots", 1)):
		fail_puzzle()
		return
	update_all()

func apply_shot_effect(shot: String, target_x: int) -> void:
	if shot == "Drive":
		opponent["stance"] = "Neutral"
		opponent["pressure"] = 1
		return

	opponent["pressure"] = 0
	match shot:
		"Drop":
			opponent["stance"] = "Forward"
		"Lob":
			opponent["stance"] = "Back"
		"Cross":
			if target_x < 2:
				opponent["stance"] = "StretchedLeft"
			elif target_x > 2:
				opponent["stance"] = "StretchedRight"
			else:
				opponent["stance"] = "Neutral"
		_:
			opponent["stance"] = "Neutral"

func compute_legal_targets(shot: String) -> Array:
	var targets: Array = []
	var ox: int = int(opponent.get("x", 2))
	var stance: String = str(opponent.get("stance", "Neutral"))
	match shot:
		"Drop":
			for dx in range(-1, 2):
				append_unique_cell(targets, clampi(ox + dx, 0, COLS - 1), 2)
		"Lob":
			for dx in range(-1, 2):
				append_unique_cell(targets, clampi(ox + dx, 0, COLS - 1), 0)
		"Cross":
			var cross_x: int = ox
			if stance == "StretchedRight":
				cross_x = clampi(ox - 2, 0, COLS - 1)
			elif stance == "StretchedLeft":
				cross_x = clampi(ox + 2, 0, COLS - 1)
			elif ox <= 2:
				cross_x = clampi(ox + 1, 0, COLS - 1)
			else:
				cross_x = clampi(ox - 1, 0, COLS - 1)
			append_unique_cell(targets, cross_x, 1)
		"Drive":
			append_unique_cell(targets, ox, 1)
	return targets

func compute_reach_cells() -> Array:
	var cells: Array = []
	var ox: int = int(opponent.get("x", 2))
	var oy: int = int(opponent.get("y", 1))
	var stance: String = str(opponent.get("stance", "Neutral"))
	var pressured: bool = int(opponent.get("pressure", 0)) > 0

	for y in range(ROWS):
		for x in range(COLS):
			var dx: int = abs(x - ox)
			var dy: int = abs(y - oy)
			var covered: bool = false
			match stance:
				"Forward":
					covered = y >= 1 and dx <= 1 and dy <= 1
				"Back":
					covered = y <= 1 and dx <= 1 and dy <= 1
				"StretchedLeft":
					covered = dx <= 1 and dy <= 1 and x <= ox + 1
				"StretchedRight":
					covered = dx <= 1 and dy <= 1 and x >= ox - 1
				_:
					covered = dx <= 1 and dy <= 1
			if pressured and covered:
				covered = dx + dy <= 1
			if covered:
				cells.append({"x": x, "y": y})
	return cells

func clear_puzzle(shot: String, target_x: int, target_y: int) -> void:
	game_over = true
	selected_shot = ""
	legal_targets = []
	var stage: Dictionary = stages[stage_index]
	lesson_label.text = "WHY IT WORKS: " + str(stage.get("lesson", "You created a landing square outside Reach."))
	result_label.text = "CHECKRALLY!\n\n%s lands at (%d,%d), outside the defender's Reach.\nSolved in %d shot(s)." % [shot, target_x, target_y, shot_count]
	result_panel.visible = true
	next_button.disabled = stage_index >= stages.size() - 1
	update_all()

func fail_puzzle() -> void:
	game_over = true
	selected_shot = ""
	legal_targets = []
	var stage: Dictionary = stages[stage_index]
	lesson_label.text = "LOOK AGAIN: " + str(stage.get("hint", "Create a weakness before trying to score."))
	result_label.text = "RALLY SURVIVED\n\nThe defender reached every shot within the limit.\nTry a sequence that changes their Reach first."
	result_panel.visible = true
	next_button.disabled = true
	update_all()

func reset_stage() -> void:
	load_stage(stage_index)

func next_stage() -> void:
	if stages.is_empty():
		return
	load_stage(mini(stage_index + 1, stages.size() - 1))

func prev_stage() -> void:
	if stages.is_empty():
		return
	load_stage(maxi(stage_index - 1, 0))

func jump_stage(index: int) -> void:
	if index < 0 or index >= stages.size():
		return
	load_stage(index)

func update_log() -> void:
	if log_lines.is_empty():
		log_label.text = "No shots yet. Read the teal Reach before choosing a shot."
		return
	log_label.text = "\n".join(log_lines)

func trim_log() -> void:
	while log_lines.size() > 4:
		log_lines.pop_back()

func append_unique_cell(array: Array, x: int, y: int) -> void:
	if not contains_cell(array, x, y):
		array.append({"x": x, "y": y})

func contains_cell(array: Array, x: int, y: int) -> bool:
	for item in array:
		var cell: Dictionary = item as Dictionary
		if int(cell.get("x", -1)) == x and int(cell.get("y", -1)) == y:
			return true
	return false

func array_has_string(array: Array, value: String) -> bool:
	for item in array:
		if str(item) == value:
			return true
	return false

func stance_explanation(stance: String, pressure: int) -> String:
	var text: String = ""
	match stance:
		"Forward":
			text = "FORWARD: strong near the net, weak behind."
		"Back":
			text = "BACK: strong deep, weak in front."
		"StretchedLeft":
			text = "STRETCHED LEFT: committed to the left side; reversing direction is costly."
		"StretchedRight":
			text = "STRETCHED RIGHT: committed to the right side; reversing direction is costly."
		_:
			text = "NEUTRAL: balanced 3x3 coverage around the defender."
	if pressure > 0:
		text += " PRESSURED: diagonal coverage is lost for the next shot."
	return text

func shot_explanation(shot: String) -> String:
	match shot:
		"Drop":
			return "DROP: choose one of three short landing squares. If reached, the defender becomes Forward."
		"Lob":
			return "LOB: choose one of three deep landing squares. If reached, the defender becomes Back."
		"Cross":
			return "CROSS: pull the defender sideways. A stretched defender is vulnerable to a reversal."
		"Drive":
			return "DRIVE: hit through the defender. It rarely wins immediately, but applies Pressure and shrinks the next Reach."
		_:
			return "Choose a shot."

func _unhandled_key_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if event.keycode == KEY_1:
		select_shot("Drop")
	elif event.keycode == KEY_2:
		select_shot("Lob")
	elif event.keycode == KEY_3:
		select_shot("Cross")
	elif event.keycode == KEY_4:
		select_shot("Drive")
	elif event.keycode == KEY_R:
		reset_stage()
	elif event.keycode == KEY_LEFT:
		prev_stage()
	elif event.keycode == KEY_RIGHT:
		next_stage()
