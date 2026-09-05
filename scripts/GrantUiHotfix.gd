extends Node

# v0.8.1 Grant-demo UI hotfix for Godot 4.7.
# Main.gd intentionally keeps the puzzle rules untouched; this node only
# rearranges and clarifies the presentation after the parent builds its UI.

const COURT_SHIFT_Y: float = 24.0
const COLOR_SOFT: Color = Color(0.78, 0.86, 0.90)

func _ready() -> void:
	call_deferred("_apply_hotfix")

func _apply_hotfix() -> void:
	var root: Control = get_parent() as Control
	if root == null:
		return

	# Top-left hierarchy: keep the puzzle title/state fully inside the left column.
	_move_label(root, "CHECKRALLY", Vector2(44, 18), Vector2(400, 40), 32)
	_move_label_prefix(root, "Think ahead.", Vector2(46, 60), Vector2(760, 26), 15)
	_move_label_prefix(root, "Puzzle ", Vector2(44, 104), Vector2(382, 30), 17)
	_move_label_prefix(root, "Opponent:", Vector2(44, 134), Vector2(382, 24), 13)
	_move_label(root, "OPPONENT COURT", Vector2(44, 164), Vector2(300, 22), 14)

	# Court cells and baseline move down as one block, eliminating title collisions.
	for child in root.get_children():
		if child is Button:
			var button: Button = child as Button
			if button.text == "" and button.position.x >= 40.0 and button.position.x <= 420.0 and button.position.y >= 165.0 and button.position.y <= 330.0:
				button.position.y += COURT_SHIFT_Y
				# Main.gd owns the semantic cell colors. This only lifts their readability.
				button.self_modulate = Color(1.30, 1.30, 1.30, 1.0)
		elif child is ColorRect:
			var rect: ColorRect = child as ColorRect
			if rect.size.y <= 6.0 and rect.size.x >= 330.0 and rect.position.y >= 370.0 and rect.position.y <= 410.0:
				rect.position.y += COURT_SHIFT_Y

	# Left-column explanatory copy and controls.
	_move_label_at(root, Vector2(56, 408), Vector2(44, 424), Vector2(382, 50), 14)
	_move_label(root, "CHOOSE A SHOT", Vector2(44, 480), Vector2(220, 22), 13)
	_reflow_shot_buttons(root)
	_reflow_nav_buttons(root)
	_move_label(root, "PUZZLES", Vector2(44, 618), Vector2(110, 22), 13)
	_reflow_stage_buttons(root)

	# Right column begins clear of the puzzle heading and gets a simpler vertical rhythm.
	_move_label(root, "READ THE COURT", Vector2(474, 110), Vector2(550, 28), 18)
	_move_label_at(root, Vector2(460, 150), Vector2(474, 144), Vector2(550, 64), 14)
	_move_label_at(root, Vector2(460, 224), Vector2(474, 214), Vector2(550, 72), 14)
	_move_label(root, "HINT", Vector2(474, 294), Vector2(100, 22), 13)
	_move_label_at(root, Vector2(460, 328), Vector2(474, 318), Vector2(550, 58), 14)
	_move_label_at(root, Vector2(460, 398), Vector2(474, 382), Vector2(550, 58), 14)
	_move_label(root, "RALLY LOG", Vector2(474, 454), Vector2(140, 22), 13)
	_move_label_at(root, Vector2(460, 500), Vector2(474, 480), Vector2(550, 100), 13)
	_move_label_prefix(root, "Teal = Reach", Vector2(474, 590), Vector2(550, 26), 12)

	# Result panel remains centered in the information column rather than covering the court.
	for child in root.get_children():
		if child is Panel:
			var panel: Panel = child as Panel
			if panel.size.x > 500.0 and panel.size.y > 200.0:
				panel.position = Vector2(468, 214)
				panel.size = Vector2(566, 260)

	_add_version_badge(root)

func _reflow_shot_buttons(root: Control) -> void:
	var x_positions: Dictionary = {
		"Drop": 44.0,
		"Lob": 140.0,
		"Cross": 236.0,
		"Drive": 332.0
	}
	for child in root.get_children():
		if child is Button:
			var button: Button = child as Button
			var clean: String = button.text.replace("[ ", "").replace(" ]", "")
			if x_positions.has(clean):
				button.position = Vector2(float(x_positions[clean]), 506)
				button.size = Vector2(88, 42)

func _reflow_nav_buttons(root: Control) -> void:
	for child in root.get_children():
		if child is Button:
			var button: Button = child as Button
			if button.text == "Retry":
				button.position = Vector2(44, 558)
				button.size = Vector2(112, 38)
			elif button.text == "< Puzzle":
				button.position = Vector2(166, 558)
				button.size = Vector2(112, 38)
			elif button.text == "Puzzle >":
				button.position = Vector2(288, 558)
				button.size = Vector2(112, 38)

func _reflow_stage_buttons(root: Control) -> void:
	var candidates: Array[Button] = []
	for child in root.get_children():
		if child is Button:
			var button: Button = child as Button
			var clean: String = button.text.replace("[", "").replace("]", "")
			if clean.is_valid_int() and int(clean) >= 1 and int(clean) <= 10:
				candidates.append(button)
	candidates.sort_custom(func(a: Button, b: Button) -> bool:
		return int(a.text.replace("[", "").replace("]", "")) < int(b.text.replace("[", "").replace("]", ""))
	)
	for i in range(candidates.size()):
		candidates[i].position = Vector2(44 + i * 39, 644)
		candidates[i].size = Vector2(34, 32)

func _move_label(root: Control, exact_text: String, pos: Vector2, new_size: Vector2, font_size: int) -> void:
	for child in root.get_children():
		if child is Label:
			var label: Label = child as Label
			if label.text == exact_text:
				_style_label(label, pos, new_size, font_size)
				return

func _move_label_prefix(root: Control, prefix: String, pos: Vector2, new_size: Vector2, font_size: int) -> void:
	for child in root.get_children():
		if child is Label:
			var label: Label = child as Label
			if label.text.begins_with(prefix):
				_style_label(label, pos, new_size, font_size)
				return

func _move_label_at(root: Control, old_pos: Vector2, pos: Vector2, new_size: Vector2, font_size: int) -> void:
	for child in root.get_children():
		if child is Label:
			var label: Label = child as Label
			if label.position.distance_to(old_pos) < 2.0:
				_style_label(label, pos, new_size, font_size)
				return

func _style_label(label: Label, pos: Vector2, new_size: Vector2, font_size: int) -> void:
	label.position = pos
	label.size = new_size
	label.add_theme_font_size_override("font_size", font_size)

func _add_version_badge(root: Control) -> void:
	var badge: Label = Label.new()
	badge.text = "Godot 4.7  •  Grant Demo v0.8.1"
	badge.position = Vector2(792, 26)
	badge.size = Vector2(250, 24)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	badge.add_theme_font_size_override("font_size", 12)
	badge.modulate = COLOR_SOFT
	root.add_child(badge)
