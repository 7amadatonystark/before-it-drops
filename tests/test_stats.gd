# Run: godot --headless -s tests/test_stats.gd
extends SceneTree

var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var stats := root.get_node("Stats")
	_check(stats.total_deaths == 0, "new run starts with no deaths")
	_check(stats.total_geo == 0, "new run starts with no geo")
	_check(stats.start_time > 0.0, "run clock is initialized")
	var started: float = stats.start_time
	_check(change_scene_to_file("res://scenes/game.tscn") == OK, "first level loads")
	await _wait_for_scene()
	var manager := get_first_node_in_group("game_manager")
	if manager == null:
		push_error("level has no game manager")
		quit(1)
		return
	_check(manager.get_node_or_null("LevelStats") != null, "tracker attaches automatically")
	manager.deaths = 3
	manager.score = 7
	await process_frame
	_check(stats.total_deaths == 0, "active level is not counted early")
	_check(reload_current_scene() == OK, "level reloads")
	await _wait_for_scene()
	_check(stats.total_deaths == 3, "outgoing level contributes once")
	_check(stats.total_geo == 7, "outgoing geo contributes once")
	_check(stats.start_time == started, "scene change preserves run clock")
	manager = get_first_node_in_group("game_manager")
	manager.deaths = 2
	manager.score = 3
	# A scene without a manager stands in for the future win/menu screen.
	var empty_scene := PackedScene.new()
	var empty_root := Node.new()
	_check(empty_scene.pack(empty_root) == OK, "destination scene packs")
	empty_root.free()
	paused = true
	_check(change_scene_to_packed(empty_scene) == OK, "paused scene change succeeds")
	_check(stats.total_deaths == 5, "total is available before destination loads")
	_check(stats.total_geo == 10, "geo is available before destination loads")
	paused = false
	await process_frame
	await process_frame
	_check(stats.total_deaths == 5, "menu frames do not duplicate deaths")
	_check(stats.total_geo == 10, "menu frames do not duplicate geo")
	_check(stats.start_time == started, "non-level scene preserves run clock")
	stats.reset()
	_check(stats.total_deaths == 0, "new run clears totals")
	_check(stats.total_geo == 0, "new run clears geo")
	_check(stats.start_time >= started, "new run restarts clock")
	root.get_node("Music").stop()
	await create_timer(0.1).timeout
	print("RESULT: ", "PASS" if failures == 0 else "FAIL", " (stats)")
	quit(0 if failures == 0 else 1)


func _check(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)


func _wait_for_scene() -> void:
	# Scene changes finish at the end of a frame (Godot 4.3 has no scene_changed signal).
	for frame in range(10):
		await process_frame
		if current_scene != null:
			# Let GameManager's own awaited _ready() frame finish before unloading it.
			await process_frame
			return
	_check(false, "scene becomes available")
