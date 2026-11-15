# ORIGIN: NEW, integration test written by team (AI-assisted).
# Run: godot --headless -s tests/test_intro.gd
extends SceneTree

const Levels = preload("res://scripts/levels.gd")
const INTRO := "res://scenes/intro.tscn"
const SELECT := "res://scenes/character_select.tscn"
const LEVEL := "res://scenes/story_level.tscn"

var failures: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, description: String) -> void:
	print(description, ": ", condition)
	if not condition:
		failures.append(description)


func _open(path: String) -> void:
	change_scene_to_file(path)
	await process_frame
	await process_frame


func _send(event: InputEvent) -> void:
	Input.parse_input_event(event)
	await process_frame


func _key(code: Key, pressed := true, echo := false) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	return event


func _pad(button: JoyButton, pressed := true) -> InputEventJoypadButton:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = pressed
	return event


func _cross() -> void:
	await _send(_pad(JOY_BUTTON_A))
	await _send(_pad(JOY_BUTTON_A, false))


func _run() -> void:
	Engine.set_meta("character", "brains")
	await _open(SELECT)
	await _cross()
	await create_timer(0.85).timeout
	_check(current_scene.scene_file_path == INTRO, "fighter selection routes CROSS to intro")
	if current_scene.scene_file_path != INTRO:
		quit(1)
		return
	var story: Label = current_scene.get_node("Margin/Content/Story")
	_check(story.text == Levels.STORY[0], "intro uses the first shared story line")
	await _send(_key(KEY_ENTER, true, true))
	await _send(_key(KEY_ENTER, false))
	_check(story.text == Levels.STORY[0], "held key repeats and releases do not skip a line")
	await _send(_key(KEY_Q))
	_check(story.visible_characters == -1, "any fresh keyboard key reveals the current line")
	await _send(_key(KEY_Q, false))
	for viewport_size in [Vector2i(1152, 648), Vector2i(640, 360), Vector2i(360, 640)]:
		root.size = viewport_size
		await process_frame
		await process_frame
		var bounds := Rect2(Vector2.ZERO, Vector2(viewport_size))
		for label_name in ["Heading", "Story", "Progress", "Prompt", "Back"]:
			var label: Label = current_scene.get_node("Margin/Content/" + label_name)
			_check(bounds.encloses(label.get_global_rect()), "%s fits %s" % [label_name, viewport_size])
		if "--capture" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			var image_path := ProjectSettings.globalize_path("res://").path_join(
				"../intro-%dx%d.png" % [viewport_size.x, viewport_size.y]).simplify_path()
			root.get_texture().get_image().save_png(image_path)
	root.size = Vector2i(1152, 648)
	for i in Levels.STORY.size():
		_check(story.text == Levels.STORY[i], "CROSS shows story line %d in order" % (i + 1))
		if story.visible_characters != -1:
			await _cross()
		_check(story.visible_characters == -1, "CROSS can reveal line %d" % (i + 1))
		await _cross()
	# Extra presses while fading must not trigger another transition.
	await _send(_pad(JOY_BUTTON_B))
	await create_timer(0.4).timeout
	_check(current_scene.scene_file_path == LEVEL, "last line starts the story once")
	_check(Engine.get_meta("level_index") == 1, "story begins at level 1")
	_check(Engine.get_meta("character") == "brains", "selected fighter survives the intro")
	_check(Engine.get_meta("raid").is_empty(), "story uses single player mode")
	await _open(INTRO)
	await _send(_pad(JOY_BUTTON_B))
	await _send(_pad(JOY_BUTTON_B, false))
	await create_timer(0.4).timeout
	_check(current_scene.scene_file_path == SELECT, "CIRCLE returns to fighter selection during typing")
	await _open(INTRO)
	await _send(_key(KEY_ESCAPE))
	await _send(_key(KEY_ESCAPE, false))
	await create_timer(0.4).timeout
	_check(current_scene.scene_file_path == SELECT, "Esc returns to fighter selection")
	await _open(INTRO)
	await create_timer(2.0).timeout
	story = current_scene.get_node("Margin/Content/Story")
	_check(story.visible_characters == -1, "typewriter finishes without input")
	_check(story.text == Levels.STORY[0], "finished line waits for confirmation")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	await _send(click)
	_check(story.text == Levels.STORY[1], "mouse click can advance a finished line")
	print("RESULT: ", "PASS" if failures.is_empty() else "FAIL")
	quit(0 if failures.is_empty() else 1)
