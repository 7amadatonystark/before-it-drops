# ORIGIN: NEW, written by team (AI-assisted).
# Exercise actual movement and visual-state handoff for solo/co-op fighters.
extends SceneTree
const PLAYER = preload("res://scenes/player.tscn")
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	print(message, ": ", condition)
	if not condition:
		failures.append(message)

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func _run() -> void:
	var stage := Node2D.new()
	root.add_child(stage)
	current_scene = stage
	var floor := StaticBody2D.new()
	floor.position.y = 30
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(4000, 20)
	collision.shape = shape
	floor.add_child(collision)
	stage.add_child(floor)
	var players: Array = []
	for fighter in ["spark", "zoom", "brains"]:
		var player = PLAYER.instantiate()
		player.char_id = fighter
		player.position.x = players.size() * 150
		stage.add_child(player)
		players.append(player)
	await frames(30)
	for player in players:
		check(player.animated_sprite.has_node("WalkPose"), player.char_id + " gets a visual walking layer")
	if not players[0].animated_sprite.has_node("WalkPose"):
		print("RESULT: FAIL (fighter animation missing)")
		quit(1)
		return
	Input.action_press("move_right")
	await frames(8)
	var phases := []
	for player in players:
		var pose = player.animated_sprite.get_node("WalkPose")
		check(pose.visible and pose.walking, player.char_id + " visibly strides while walking")
		check(player.animated_sprite.self_modulate.a == 0.0, player.char_id + " hides the unposed duplicate")
		check(player.velocity.x == 130.0, player.char_id + " retains normal movement speed")
		phases.append(pose.phase)
	await frames(8)
	for i in players.size():
		var pose = players[i].animated_sprite.get_node("WalkPose")
		check(not is_equal_approx(pose.phase, phases[i]), players[i].char_id + " stride advances during movement")
	# Combat owns its visual pose; stopping one co-op fighter cannot stop the others.
	players[1].attack_anim_t = 0.3
	await frames(2)
	check(not players[1].animated_sprite.get_node("WalkPose").visible, "attack restores original fighter art")
	check(players[1].animated_sprite.self_modulate.a == 1.0, "attack sprite remains visible")
	check(players[0].animated_sprite.get_node("WalkPose").walking, "other co-op fighter keeps walking")
	Input.action_release("move_right")
	Input.action_press("move_left")
	await frames(8)
	check(players[0].animated_sprite.get_node("WalkPose").scale.x == -1.0, "walking pose faces left with player")
	Input.action_release("move_left")
	await frames(3)
	for player in players:
		check(not player.animated_sprite.get_node("WalkPose").visible, player.char_id + " stops striding at rest")
		check(player.animated_sprite.self_modulate.a == 1.0, player.char_id + " restores original idle art")
	Input.action_press("move_right")
	Input.action_press("jump")
	await frames(3)
	check(not players[0].is_on_floor(), "jump still leaves the ground")
	check(not players[0].animated_sprite.get_node("WalkPose").visible, "airborne fighter uses original jump pose")
	check(players[0].animated_sprite.self_modulate.a == 1.0, "jump sprite stays visible")
	Input.action_release("move_right")
	Input.action_release("jump")
	players[0].controllable = false
	await frames(2)
	check(not players[0].animated_sprite.get_node("WalkPose").visible, "uncontrollable/dead fighter never keeps walking")
	print("RESULT: ", "PASS" if failures.is_empty() else "FAIL", " (fighter animation)")
	quit(0 if failures.is_empty() else 1)
