# ORIGIN: NEW, written by team (AI-assisted).
# Zero-death Roof witness: flame pogo, spike pogo/dash, Line Cutter, physical exit.
# Fresh level, live enemies, real inputs. No body/health/position overrides.
# Godot 4.3: godot --headless --fixed-fps 60 -s tests/test_min_deaths_roof.gd -- 3 spark
# Repeat with zoom and brains. The test observes deaths through the scene change.
extends "res://tests/test_story_routes.gd"
var jump_frame := 295
var side_offset := 14.0
var did_pogo := false
var pogo_frame := -1
var combat := false
var spike_mode := false
var min_y := 1000.0
func tick(n := 1):
	for i in n:
		await physics_frame
		frame += 1
		if combat:
			Input.action_release("attack")
			if frame%20==0: Input.action_press("attack")
		elif spike_mode:
			Input.action_release("attack")
			if frame%2==0 and pl.position.y>=67 and pl.velocity.y>0 and pl.attack_cd<=0:
				Input.action_press("attack")
func run():
	if level != 3:
		push_error("This witness is for Level 3; pass -- 3 <fighter>")
		quit(2)
		return
	var args=OS.get_cmdline_user_args()
	if args.size()>2: jump_frame=int(args[2])
	if args.size()>3: side_offset=float(args[3])
	await process_frame
	await tick(15)
	pl=get_first_node_in_group("player")
	gm=get_first_node_in_group("game_manager")
	var flame
	for child in current_scene.get_children():
		if child.get_script()==preload("res://scripts/guard.gd"): flame=child
	while frame<jump_frame: await tick()
	Input.action_press("jump")
	Input.action_press("move_down")
	var prev_vy:=0.0
	for i in 240:
		if gm.deaths>0: break
		Input.action_release("attack")
		if not did_pogo:
			steer(clampf(flame.position.x-side_offset, 24, 118))
			if frame%2==0 and absf(flame.position.x-pl.position.x)<23 and pl.position.y>flame.position.y-48 and pl.position.y<flame.position.y-5 and not pl.is_on_floor() and pl.attack_cd<=0:
				Input.action_press("attack")
		else:
			steer(170)
			if frame-pogo_frame==10: Input.action_press("dash")
			if frame-pogo_frame==12: Input.action_release("dash")
		await tick()
		if pl.attack_cd>0 and pl.velocity.y<-290 and prev_vy>-240:
			did_pogo=true
			pogo_frame=frame
		prev_vy=pl.velocity.y
		min_y=minf(min_y,pl.position.y)
		if did_pogo and pl.is_on_floor() and absf(pl.position.y-96)<3 and pl.position.x>150:
			print("ZERO FIRST GATE PASS ",fighter," ",jump_frame," ",side_offset," masks ",gm.masks)
			await finish_route()
			return
	print("ZERO FIRST GATE FAIL ",fighter," ",jump_frame," ",side_offset," min_y ",min_y," deaths ",gm.deaths," pos ",pl.position)
	print("RESULT: FAIL")
	quit(1)

func finish_route():
	Input.action_release("jump")
	Input.action_release("move_down")
	Input.action_release("dash")
	var ok=await walk(184)
	spike_mode=true
	await tick(2)
	Input.action_press("jump")
	Input.action_press("move_down")
	var landed=false
	var top=1000.0
	var second_pogo=-1
	var second_prev=0.0
	for i in 240:
		steer(330)
		if second_pogo>=0 and frame-second_pogo==10: Input.action_press("dash")
		if second_pogo>=0 and frame-second_pogo==12: Input.action_release("dash")
		await tick()
		if pl.attack_cd>0 and pl.velocity.y<-290 and second_prev>-240: second_pogo=frame
		second_prev=pl.velocity.y
		top=minf(top,pl.position.y)
		if gm.deaths>0: break
		if pl.is_on_floor() and absf(pl.position.y-32)<3 and absf(pl.position.x-330)<5:
			landed=true
			break
	print("ZERO SECOND GATE ",landed," at ",pl.position," deaths ",gm.deaths," top ",top)
	ok=landed and ok
	spike_mode=false
	combat=true
	Input.action_release("jump")
	Input.action_release("move_down")
	if ok:
		ok=await walk(405) and ok
		ok=await fight_gate() and ok
		if not current_scene.done:
			Input.action_release("dash")
			if pl.is_on_floor():
				Input.action_release("jump")
				await tick(2)
			Input.action_press("jump")
			for i in 600:
				if current_scene.done or gm.deaths>0:break
				steer(616)
				if pl.is_on_floor() and i>30:
					if i%40==0:Input.action_release("jump")
					if i%40==2:Input.action_press("jump")
				if i>10 and not pl.is_on_floor() and pl.can_air_dash and pl.dash_cd<=0:
					Input.action_press("dash")
				else:Input.action_release("dash")
				await tick()
	var deaths=gm.deaths
	if ok:
		for i in 200:
			await physics_frame
			if is_instance_valid(gm):deaths=maxi(deaths,gm.deaths)
			if current_scene and current_scene.name=="BossArena":break
		ok=current_scene != null and current_scene.name=="BossArena" and deaths==0 and ok
	print("ZERO ROOF ",fighter," ",ok," deaths ",deaths)
	print("RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
