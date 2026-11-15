# ORIGIN: NEW, written by team (AI-assisted).
# Each optional high coin is reached by real inputs and an existing body bounce.
# Godot 4.3: godot --headless --fixed-fps 60 -s tests/test_story_secrets.gd -- 1 spark
extends "res://tests/test_story_routes.gd"

func run():
	await process_frame
	await tick(15)
	pl = get_first_node_in_group("player")
	gm = get_first_node_in_group("game_manager")
	var secret_x: float = [648.0, 904.0, 72.0][level - 1]
	var coin
	for child in current_scene.get_children():
		if child.get_script() == preload("res://scripts/coin.gd") and child.global_position.is_equal_approx(Vector2(secret_x, 24)):
			coin = child
			break
	if coin == null:
		print("RESULT: FAIL (no high secret coin in level %d)" % level)
		quit(1)
		return
	var coin_bottom: float = 24 + coin.get_node("CollisionShape2D").shape.radius
	var contact := {"player_touched": false}
	coin.body_entered.connect(func(who):
		if who == pl: contact.player_touched = true)
	var ok := true
	if level == 1:
		ok = await walk(263)
		ok = await jump(361, 176) and ok
		ok = await jump(432, 160) and ok
		ok = await jump(500, 176) and ok
		ok = await walk(536) and ok
		ok = await sacrifice(664) and ok
	elif level == 2:
		ok = await walk(144)
		ok = await jump(200, 176) and ok
		ok = await jump(248, 176) and ok
		ok = await jump(296, 176) and ok
		ok = await jump(370, 176) and ok
		ok = await walk(510) and ok
		ok = await jump(640, 176, 180, true) and ok
		ok = await walk(696) and ok
		ok = await sacrifice(920) and ok
	else:
		ok = await sacrifice(104)
	# Ledge top is at y48; ordinary terrain nearby tops out at y96.
	if gm.bodies.is_empty():
		print("RESULT: FAIL (no body for secret route)")
		quit(1)
		return
	var secret_body = gm.bodies[-1]
	var before: int = gm.score
	ok = await bounce_to(secret_x + 8, 48) and ok
	var on_ledge: bool = absf(pl.position.y - 48) < 3 and pl.is_on_floor()
	var min_y: float = pl.position.y
	Input.action_release("jump")
	await tick(2)
	Input.action_press("jump")
	for i in 50:
		steer(secret_x)
		await tick()
		min_y = minf(min_y, pl.position.y)
	Input.action_release("jump")
	var rise: float = 48.0 - min_y
	# The actual player's full jump from the highest nearby ordinary terrain
	# would leave even the top of its collision circle below this coin.
	var player_top_offset: float = pl.collision.position.y - pl.collision.shape.radius
	var ordinary_top := INF
	for cell in current_scene.tilemap.get_used_cells(1):
		# Ignore the map's outer boundary walls, which are not an approach.
		if cell.x == 0 or cell.x == current_scene.width - 1:
			continue
		if absf(cell.x * 16 + 8 - secret_x) <= 160:
			ordinary_top = minf(ordinary_top, cell.y * 16)
	for child in current_scene.get_children():
		if child is AnimatableBody2D and absf(child.position.x - secret_x) <= 160:
			var top: float = child.position.y - 4
			if not is_equal_approx(top, 48):
				ordinary_top = minf(ordinary_top, top)
	var needs_boost: bool = is_finite(ordinary_top) and ordinary_top - rise + player_top_offset > coin_bottom
	var rewarded: bool = contact.player_touched and gm.score >= before + 1
	ok = on_ledge and rewarded and needs_boost and ok
	print("secret_ledge_reached: ", on_ledge)
	print("secret_coin_rewarded: ", rewarded)
	print("above_nearby_normal_jump_pickup: ", needs_boost)
	# Return to the normal route without another forced death.
	var d0: int = gm.deaths
	if level == 1:
		# Drop onto safe ground left of the spikes, then reuse the body to
		# reach the exit deck. This also works after a scalper knocks us back.
		var safe_x: float = secret_body.position.x - 24
		var landed := false
		for i in 180:
			steer(safe_x)
			await tick()
			if pl.is_on_floor() and absf(pl.position.y - 176) < 3:
				landed = true
				break
		ok = landed and ok
		ok = await bounce_to(770, 96, 240, secret_body) and ok
	elif level == 2:
		ok = await jump(1000, 96) and ok
	else:
		ok = await jump(170, 96) and ok
		ok = await walk(184) and ok
	ok = gm.deaths == d0 and ok
	print("returned_without_death: ", gm.deaths == d0)
	print("SECRET: level ", level, " ", fighter)
	print("RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
