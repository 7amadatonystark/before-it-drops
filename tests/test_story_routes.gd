# ORIGIN: NEW, written by team (AI-assisted).
# Scripted story playtest with real inputs, enemies, health, and scene transitions.
# No teleporting, health overrides, enemy removal, or movement changes.
# Godot 4.3: godot --headless --fixed-fps 60 -s tests/test_story_routes.gd -- 1 spark
# Arguments select one of nine routes. Fixed seed makes enemy movement reproducible.
extends SceneTree
var pl
var gm
var level := 1
var fighter := "spark"
var frame := 0
var seen_deaths := 0
var physics_frames := 0

func _physics_process(_delta):
	physics_frames += 1
	if physics_frames >= 6000:
		print("RESULT: FAIL (physics watchdog)")
		quit(1)
	return false

func _initialize():
	var args = OS.get_cmdline_user_args()
	if args.size() > 0: level = int(args[0])
	if args.size() > 1: fighter = args[1]
	if level not in [1, 2, 3] or fighter not in ["spark", "zoom", "brains"]:
		push_error("Usage: -- <level 1-3> <spark|zoom|brains>")
		quit(2)
		return
	seed(12345)
	Engine.set_meta("level_index", level)
	Engine.set_meta("character", fighter)
	change_scene_to_file("res://scenes/story_level.tscn")
	call_deferred("run")
func tick(n := 1):
	for i in n:
		await physics_frame
		frame += 1
		if frame > 5000:
			print("RESULT: FAIL (route watchdog)")
			quit(1)
			return
		if gm and gm.deaths > seen_deaths:
			seen_deaths = gm.deaths
			print("DEATH ",seen_deaths," at ",pl.position," frame ",frame)
		# Exercise actual inputs; don't grant health or move the player by script.
		Input.action_release("attack")
		if frame % 20 == 0: Input.action_press("attack")
func steer(x: float):
	Input.action_release("move_left")
	Input.action_release("move_right")
	if absf(pl.position.x-x)>2:
		Input.action_press("move_right" if pl.position.x<x else "move_left")
func walk(x: float, limit := 500):
	for i in limit:
		steer(x)
		if absf(pl.position.x-x)<3: steer(pl.position.x); return true
		await tick()
	print("WALK FAIL ", x, " at ", pl.position, " deaths ",gm.deaths)
	return false
func jump(x: float, y: float, limit := 180, dash := false):
	Input.action_release("jump")
	await tick(2)
	Input.action_press("jump")
	for i in limit:
		steer(x)
		if i > 40 and i % 40 == 0 and pl.is_on_floor():
			Input.action_release("jump")
		if i > 40 and i % 40 == 2 and pl.is_on_floor():
			Input.action_press("jump")
		if dash and i == 14: Input.action_press("dash")
		if dash and i == 16: Input.action_release("dash")
		await tick()
		if absf(pl.position.x-x)<5 and absf(pl.position.y-y)<3 and pl.is_on_floor():
			Input.action_release("jump"); steer(pl.position.x); return true
	print("JUMP FAIL ", Vector2(x,y), " at ",pl.position," vy ",pl.velocity.y," deaths ",gm.deaths)
	Input.action_release("jump")
	return false
func bounce_to(x: float, y: float, limit := 240, pad = null):
	if gm.bodies.is_empty():
		print("BOUNCE FAIL: no body")
		return false
	var bx = pad.position.x if is_instance_valid(pad) else gm.bodies[-1].position.x
	await walk(bx - 24)
	Input.action_release("jump")
	await tick(2)
	Input.action_press("jump")
	var bounced = false
	for i in limit:
		steer(x if bounced else bx)
		await tick()
		if pl.velocity.y < -350: bounced = true
		if bounced and absf(pl.position.x-x)<5 and absf(pl.position.y-y)<3 and pl.is_on_floor():
			Input.action_release("jump"); steer(pl.position.x); return true
	print("BOUNCE FAIL ",Vector2(x,y)," at ",pl.position," deaths ",gm.deaths)
	Input.action_release("jump")
	return false
func sacrifice(x: float):
	var d = gm.deaths
	for i in 400:
		steer(x)
		await tick()
		if gm.deaths > d:
			steer(pl.position.x)
			for wait_frame in 180:
				if not pl.is_dead: break
				await tick()
			if pl.is_dead: return false
			await tick(25)
			print("BODY ",gm.bodies[-1].position," respawn ",pl.position)
			return true
	print("NO DEATH ",pl.position)
	return false
func fight_gate(limit := 1800):
	Input.action_release("jump")
	await tick(2)
	for i in limit:
		var enemies = get_nodes_in_group("gatekeeper").filter(func(e): return not e.has_meta("dying"))
		if enemies.is_empty():
			Input.action_release("move_down")
			Input.action_release("jump")
			print("GATE BEATEN ",fighter," deaths ",gm.deaths)
			return true
		var e = enemies[0]
		if pl.is_dead:
			await tick()
			continue
		if pl.position.y > 80:
			# A real death returns us to the bench; climb back using the
			# existing spike body instead of stalling below the fight.
			var pads = gm.bodies.filter(func(p): return absf(p.position.y - 96) < 5 and p.position.x > 220 and p.position.x < 270)
			if pads.is_empty() or not await bounce_to(330, 32, 240, pads[0]):
				print("GATE FAIL: cannot return from bench")
				return false
			continue
		var dx = e.position.x-pl.position.x
		# Brute knockback can push the non-physics rival off the roof.
		# Recover with a real jump/dash and pogo from its left, pushing it
		# back toward the arena. No enemy position is changed by the test.
		if fighter == "zoom" and e.position.x < 288:
			steer(e.position.x - 12)
			Input.action_press("move_down")
			Input.action_press("jump")
			if not pl.is_on_floor() and absf(dx) > 55 and pl.can_air_dash:
				Input.action_press("dash")
			else:
				Input.action_release("dash")
			await tick()
			continue
		Input.action_release("dash")
		if pl.is_on_floor():
			Input.action_release("move_down")
			Input.action_release("jump")
			steer(clampf(e.position.x - 31 if dx>0 else e.position.x+31, 304, 646))
			if absf(dx)<45:
				if signf(dx) != pl.facing:
					steer(pl.position.x + signf(dx) * 16)
			if e.state=="tell" and e.state_t < 0.13:
				Input.action_press("jump")
		else:
			Input.action_press("move_down")
			steer(clampf(e.position.x, 304, 646))
		if i%160==0 and fighter != "zoom":
			Input.action_press("special")
		else: Input.action_release("special")
		if gm.soul>=33:
			Input.action_press("power")
		else: Input.action_release("power")
		await tick()
	print("GATE FAIL ",fighter," pos ",pl.position," deaths ",gm.deaths)
	for enemy in get_nodes_in_group("gatekeeper"):
		print("GATE DIAGNOSTIC: pos=", enemy.position, " hp=", enemy.get_meta("hp"), " state=", enemy.state, " facing=", pl.facing, " soul=", gm.soul)
	return false
func run():
	await process_frame
	await tick(15)
	pl = get_first_node_in_group("player")
	gm = get_first_node_in_group("game_manager")
	print("START ",level," ",fighter," ",pl.position)
	var ok = true
	if level == 1:
		ok = await walk(263)
		ok = await jump(361,176) and ok
		ok = await jump(432,160) and ok
		ok = await jump(500,176) and ok
		ok = await walk(536) and ok
		ok = await sacrifice(664) and ok
		ok = await bounce_to(770,96) and ok
	elif level == 2:
		ok = await walk(144)
		ok = await jump(200,176) and ok
		ok = await jump(248,176) and ok
		ok = await jump(296,176) and ok
		ok = await jump(370,176) and ok
		ok = await walk(510) and ok
		ok = await jump(640,176,180,true) and ok
		ok = await walk(696) and ok
		ok = await sacrifice(920) and ok
		ok = await bounce_to(1000,96) and ok
	elif level == 3:
		ok = await sacrifice(104)
		ok = await bounce_to(170,96) and ok
		ok = await walk(184) and ok
		ok = await sacrifice(256) and ok
		ok = await bounce_to(330,32) and ok
	if level == 3:
		ok = await walk(405) and ok
		current_scene._on_exit(pl)
		ok = not current_scene.done and ok
		print("GATE LOCKED ", not current_scene.done)
		ok = await fight_gate() and ok
	if ok:
		if level == 3: ok = await walk(550) and ok
		ok = await walk([792,1000,616][level-1]) and ok
	var deaths = gm.deaths
	if ok:
		for i in 200:
			await physics_frame
			if current_scene and ((level<3 and current_scene.get("index")==level+1) or (level==3 and current_scene.name=="BossArena")):
				print("EXIT TRANSITION OK ",level)
				break
		if level==3: ok = ok and current_scene.name=="BossArena"
		else: ok = ok and current_scene.get("index")==level+1
	print("ROUTE: level ", level, " ", fighter, " deaths ", deaths)
	print("RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
