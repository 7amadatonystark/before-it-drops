extends SceneTree
var failures := 0
func _initialize() -> void:
	_run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _run() -> void:
	var feel := root.get_node_or_null("GameFeel")
	var transition := root.get_node_or_null("SceneTransition")
	check(feel != null and transition != null, "feel and transition autoloads exist")
	if not feel or not transition:
		print("RESULT: FAIL (feel missing)")
		quit(1)
		return
	Engine.set_meta("raid", [{"device": -2, "char": "spark"}, {"device": 0, "char": "zoom"}])
	change_scene_to_file("res://scenes/boss_arena.tscn")
	for i in 6:
		await process_frame
	var players := get_nodes_in_group("player")
	check(players.size() == 2, "raid has two observable players")
	for p in players:
		p.set_physics_process(false)
	feel._physics_process(0.016)
	check(feel.flash.color.a == 0.0, "spawn never flashes")
	players[1].pmasks -= 1
	feel._physics_process(0.016)
	check(feel.flash.color.a > 0.0, "second player damage flashes")
	await create_timer(0.1).timeout
	check(feel.flash.color.a == 0.0, "white flash expires")
	var p = players[1]
	p.velocity.y = 0
	feel._physics_process(0.016)
	p.velocity.y = -450
	feel._physics_process(0.016)
	check(feel.effects.get_child_count() == 2, "body bounce creates popup and dust")
	feel._physics_process(0.016)
	check(feel.effects.get_child_count() == 2, "sustained launch does not repeat")
	p.velocity.y = 0
	feel._physics_process(0.016)
	p.slash_dir = Vector2.DOWN
	p.slash_t = 0.1
	p.velocity.y = -300
	feel._physics_process(0.016)
	check(feel.effects.get_child_count() == 3, "downward pogo creates spark")
	await create_timer(1.0).timeout
	check(feel.effects.get_child_count() == 0, "temporary effects clean up")
	change_scene_to_file("res://scenes/character_select.tscn")
	for i in 4:
		await process_frame
	check(transition.cover.color.a > 0.0, "scene change dips to black")
	await create_timer(0.5).timeout
	check(transition.cover.color.a == 0.0, "transition releases screen")
	check(feel.effects.get_child_count() == 0, "effects clear outside gameplay")
	Engine.set_meta("raid", [])
	root.get_node("Music").stop()
	await create_timer(0.1).timeout
	print("RESULT: ", "PASS" if failures == 0 else "FAIL", " (feel)")
	quit(0 if failures == 0 else 1)
