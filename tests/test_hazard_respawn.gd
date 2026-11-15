# Regression: falling into a pit during hit immunity must still respawn the player.
# Run: godot --headless -s tests/test_hazard_respawn.gd
extends SceneTree

var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	change_scene_to_file("res://scenes/game.tscn")
	while current_scene == null:
		await process_frame
	var manager := get_first_node_in_group("game_manager")
	while manager.player == null:
		await process_frame
	var player: CharacterBody2D = manager.player
	root.get_node("Music").stop()
	await create_timer(0.3).timeout
	var safe_position: Vector2 = player.last_safe

	manager.player_hit(player.global_position + Vector2(10, 0))
	_check(manager.masks == 4, "enemy hit removes one mask")
	manager.player_hit(player.global_position + Vector2(10, 0))
	_check(manager.masks == 4, "immunity still blocks repeat enemy hits")
	_drop_into_pit(player)
	await create_timer(1.0).timeout
	print("After hazard: masks=", manager.masks, " pos=", player.global_position, " safe=", player.last_safe)
	_check(manager.masks == 3, "pit removes one mask during immunity")
	_check(player.global_position.y < 141.0, "pit returns player above the level boundary")
	_check(player.controllable and not manager.dead, "player can move after hazard respawn")

	manager.masks = 1
	player.last_safe = safe_position
	_drop_into_pit(player)
	await create_timer(1.2).timeout
	print("After death: masks=", manager.masks, " pos=", player.global_position, " deaths=", manager.deaths)
	_check(manager.deaths == 1, "lethal pit completes the death sequence during immunity")
	_check(manager.bodies.size() == 1, "lethal pit leaves exactly one body")
	_check(manager.masks == manager.MAX_MASKS, "death restores health")
	_check(player.global_position.y < 141.0, "death returns player to the level")
	_check(player.controllable and not manager.dead, "death restores control")
	print("RESULT: ", "PASS" if failures == 0 else "FAIL", " (hazard respawn)")
	quit(0 if failures == 0 else 1)


func _drop_into_pit(player: CharacterBody2D) -> void:
	player.invuln = 0.8
	# Teleporting is just the test setup; do not record that air position as safe ground.
	player.safe_t = 0.2
	player.global_position = Vector2(2048, 120)
	player.velocity = Vector2(0, 250)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)
