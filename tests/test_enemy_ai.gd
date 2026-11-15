# ORIGIN: NEW, written by team.
# Real enemies on real narrow platforms, hazards, walls, and all story maps.
extends SceneTree
const Guard = preload("res://scripts/guard.gd")
const Rival = preload("res://scripts/rival.gd")
const Navigation = preload("res://scripts/enemy_navigation.gd")
const PLAYER = preload("res://scenes/player.tscn")
const KILLZONE = preload("res://scenes/killzone.tscn")
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	print(message, ": ", condition)
	if not condition:
		failures.append(message)

func ticks(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func floor_at(parent: Node2D, center: Vector2, size: Vector2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = "Floor"
	body.position = center
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	parent.add_child(body)
	return body

func stage(width: float) -> Node2D:
	if current_scene:
		current_scene.queue_free()
		await process_frame
	var room := Node2D.new()
	root.add_child(room)
	current_scene = room
	floor_at(room, Vector2(0, 8), Vector2(width, 16))
	var player = PLAYER.instantiate()
	player.position = Vector2(100, 0)
	room.add_child(player)
	player.set_physics_process(false)
	player.invuln = 1000.0
	await ticks(3)
	return room

func spawn(room: Node2D, kind: String, at := Vector2.ZERO):
	var enemy = Guard.new() if kind in ["lolli", "smug", "flame"] else Rival.new()
	enemy.kind = kind
	enemy.position = at
	room.add_child(enemy)
	return enemy

func _run() -> void:
	seed(12345)
	Engine.set_meta("character", "")
	Engine.set_meta("raid", [])
	for kind in ["lolli", "smug", "flame", "scalper", "streamer", "preorder", "line_cutter"]:
		var room := await stage(16)
		var enemy = spawn(room, kind)
		var safe := true
		var min_x := 0.0
		var max_x := 0.0
		var stunned := false
		for frame in 240:
			await ticks(1)
			safe = safe and absf(enemy.position.x) <= 6.1 and absf(enemy.position.y) <= 1.0
			min_x = minf(min_x, enemy.position.x)
			max_x = maxf(max_x, enemy.position.x)
			if kind == "line_cutter" and enemy.state == "stunned":
				stunned = true
		check(safe, kind + " stays on a one-tile platform with a player across the gap")
		check(max_x - min_x > 2.0, kind + " can still move rather than freezing at spawn")
		if kind == "line_cutter":
			check(stunned, "Line Cutter stops and becomes vulnerable before charging off an edge")
	# A high-speed fall must sweep through the floor, not miss a short landing ray.
	for kind in ["lolli", "streamer"]:
		var room := await stage(128)
		var enemy = spawn(room, kind, Vector2(0, -60))
		enemy.vel_y = 900.0
		enemy._warmup = 0
		await ticks(12)
		check(absf(enemy.position.y) < 0.1, kind + " lands safely at high fall speed")
	var room := await stage(160)
	var flame = spawn(room, "flame")
	flame.hop_t = 0.0
	var jumped := false
	var landed := false
	for frame in 120:
		await ticks(1)
		jumped = jumped or flame.position.y < -20.0
		if jumped and absf(flame.position.y) < 0.1 and flame.vel_y == 0.0:
			landed = true
			break
	check(jumped and landed, "flame still performs and lands a safe attack hop")
	room = await stage(160)
	var hazard = KILLZONE.instantiate()
	hazard.instant_kill = true
	hazard.leaves_body = false
	hazard.position = Vector2(20, -2)
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(12, 4)
	shape.shape = box
	hazard.add_child(shape)
	room.add_child(hazard)
	var walker = spawn(room, "lolli")
	walker.dir = 1.0
	var avoids_spikes := true
	for frame in 240:
		await ticks(1)
		avoids_spikes = avoids_spikes and walker.position.x < 12.1
	check(avoids_spikes, "patrol turns before death spikes")
	room = await stage(200)
	floor_at(room, Vector2(25, -16), Vector2(8, 32))
	var scalper = spawn(room, "scalper")
	scalper.dir = 1.0
	var avoids_wall := true
	for frame in 240:
		await ticks(1)
		avoids_wall = avoids_wall and scalper.position.x < 14.0
	check(avoids_wall, "patrol turns before its body clips a wall")
	check(not Navigation.has_sight(scalper, get_first_node_in_group("player"), 26), "solid wall blocks target visibility")
	var shots := room.get_children().filter(func(n): return n.get_script() == preload("res://scripts/enemy_shot.gd"))
	check(shots.is_empty(), "scalper does not fire through a solid wall")
	room = await stage(32)
	room.get_node("Floor").position.x = -16
	floor_at(room, Vector2(40, 8), Vector2(48, 16))
	await ticks(3)
	var charger = spawn(room, "line_cutter", Vector2(-10, 0))
	charger._warmup = 0
	charger.dir = 1.0
	charger.state = "charge"
	charger.state_t = 1.0
	charger._physics_process(0.25)
	check(charger.position.x < 0 and charger.state == "stunned", "long physics step cannot teleport a charge across a gap")
	# The reported bug passed the old two-frame layout test. Watch ten full seconds.
	for level in [1, 2, 3]:
		Engine.time_scale = 1.0
		Engine.set_meta("level_index", level)
		change_scene_to_file("res://scenes/story_level.tscn")
		await process_frame
		await process_frame
		var enemies := {}
		for enemy in current_scene.get_children():
			if enemy.get_script() in [Guard, Rival]:
				enemies[enemy] = enemy.position
		for player in get_nodes_in_group("player"):
			player.controllable = false
			player.invuln = 1000.0
		var fallen := {}
		for frame in 600:
			await ticks(1)
			for enemy in enemies:
				if is_instance_valid(enemy) and enemy.position.y > enemies[enemy].y + 8.0:
					fallen[enemy] = enemy.kind
		check(fallen.is_empty(), "level %d: all %d enemies remain on platforms for ten seconds (%s)" % [level, enemies.size(), fallen.values()])
	Engine.time_scale = 1.0
	print("RESULT: ", "PASS" if failures.is_empty() else "FAIL", " (enemy AI)")
	quit(0 if failures.is_empty() else 1)
