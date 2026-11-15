# ORIGIN: NEW, written by team (AI-assisted).
# Story coins must award exactly one GEO to a player, then disappear.
extends SceneTree

func _initialize():
	Engine.set_meta("level_index", 1)
	change_scene_to_file("res://scenes/story_level.tscn")
	call_deferred("_run")

func _run():
	await process_frame
	await physics_frame
	var gm = get_first_node_in_group("game_manager")
	var player = get_first_node_in_group("player")
	var coin
	for child in current_scene.get_children():
		if child.get_script() == preload("res://scripts/coin.gd"):
			coin = child
			break
	if coin == null:
		print("RESULT: FAIL (no story coin)")
		quit(1)
		return
	# Place an isolated collision fixture at an actual generated coin. Route tests
	# separately verify movement; this test checks the pickup and reward boundary.
	player.controllable = false
	player.global_position = coin.global_position + Vector2(0, 5)
	var before: int = gm.score
	for i in 10: await physics_frame
	var awarded: bool = gm.score == before + 1
	# Re-enter while the pickup animation is still running.
	var pickup_position = player.global_position
	player.global_position += Vector2(80, 0)
	for i in 2: await physics_frame
	player.global_position = pickup_position
	for i in 2: await physics_frame
	for i in 80: await physics_frame
	var removed: bool = not is_instance_valid(coin)
	var once: bool = gm.score == before + 1
	print("awarded_one_geo: ", awarded)
	print("removed_after_pickup: ", removed)
	print("awarded_once: ", once)
	var ok := awarded and removed and once
	print("RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
