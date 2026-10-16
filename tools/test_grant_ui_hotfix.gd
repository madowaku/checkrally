extends SceneTree

# Run from the Checkrally project root:
# godot --headless --path . --script res://tools/test_grant_ui_hotfix.gd

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/Main.tscn")
	if scene == null:
		push_error("Could not load Checkrally main scene")
		quit(1)
		return

	var game: Control = scene.instantiate() as Control
	root.add_child(game)
	# The hotfix uses call_deferred, so wait for the scene and deferred pass.
	await process_frame
	await process_frame

	var cells: Array = game.get("cell_buttons")
	if cells.size() != 15:
		push_error("Expected 15 court cells, got %d" % cells.size())
		quit(1)
		return

	var opponent_count: int = 0
	for i in range(cells.size()):
		var cell: Button = cells[i] as Button
		if cell.text == "O":
			opponent_count += 1
		var expected := Vector2(56 + (i % 5) * 72, 170 + floori(float(i) / 5.0) * 72 + 24)
		if not cell.position.is_equal_approx(expected):
			push_error("Court cell %d at %s; expected %s" % [i, cell.position, expected])
			quit(1)
			return

	if opponent_count != 1:
		push_error("Expected exactly one opponent cell, got %d" % opponent_count)
		quit(1)
		return

	print("PASS: all 15 court cells, including opponent, shifted 24px")
	quit(0)
