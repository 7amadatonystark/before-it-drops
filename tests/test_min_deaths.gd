# ORIGIN: NEW, written by team (AI-assisted).
# Zero-death witnesses for Docks and Neon Streets, including scene transitions.
# Uses live enemies and real inputs, with no health/position overrides.
# Godot 4.3: godot --headless --fixed-fps 60 -s tests/test_min_deaths.gd -- 1 spark
# Repeat for levels 1/2 and spark/zoom/brains. Default timing is the verified route.
extends "res://tests/test_story_routes.gd"
var combat := true
var approach := 800.0
var initial_dash := false
func tick(n := 1):
	for i in n:
		await physics_frame
		frame+=1
		if combat:
			Input.action_release("attack")
			if frame%20==0: Input.action_press("attack")
func run():
	if level not in [1, 2]:
		push_error("Use tests/test_min_deaths_roof.gd for Level 3")
		quit(2)
		return
	initial_dash = level == 2
	var args=OS.get_cmdline_user_args()
	if args.size()>2:approach=float(args[2])
	if args.size()>3:initial_dash=bool(int(args[3]))
	combat=fighter!="zoom"
	await process_frame
	await tick(15)
	pl=get_first_node_in_group("player")
	gm=get_first_node_in_group("game_manager")
	var ok=true
	if level==1:
		ok=await walk(263)
		ok=await jump(361,176) and ok
		ok=await jump(432,160) and ok
		ok=await jump(500,176) and ok
		ok=await walk(536) and ok
		combat=false
		Input.action_release("attack")
		ok=await walk(600) and ok
		var target
		for e in current_scene.get_children():
			if e.get_script()==preload("res://scripts/rival.gd") and e.kind=="streamer":target=e
		var ready=false
		for i in 900:
			if not is_instance_valid(target) or gm.deaths>0:break
			steer(600)
			if target.position.x>650 and target.position.x<675 and target.dir<0 and pl.is_on_floor() and pl.stun<=0:
				ready=true
				break
			await tick()
		if not ready:ok=false
		else:ok=await pogo_enemy(target,770,96) and ok
	else:
		var lift
		for e in current_scene.get_children():
			if e.get_script()==preload("res://scripts/guard.gd") and e.kind=="lolli" and e.position.x>630 and e.position.x<670: lift=e
		combat=true
		ok=await walk(144)
		ok=await jump(200,176) and ok
		ok=await jump(248,176) and ok
		ok=await jump(296,176) and ok
		ok=await jump(370,176) and ok
		ok=await walk(510) and ok
		ok=await jump(640,176,180,true) and ok
		ok=await walk(696) and ok
		combat=false
		Input.action_release("attack")
		ok=await walk(approach) and ok
		var ready=false
		for i in 1200:
			if not is_instance_valid(lift) or gm.deaths>0: break
			steer(approach)
			if lift.position.x>=850 and lift.position.x<=930 and pl.is_on_floor() and pl.stun<=0:
				ready=true
				break
			await tick()
		if not ready:ok=false
		else:ok=await pogo_enemy(lift,1000,96) and ok
	print("ZERO REACHED ",level," ",fighter," ",ok," deaths ",gm.deaths," at ",pl.position)
	if ok:
		combat=true
		ok=await walk(792 if level==1 else 1000) and ok
		var d=gm.deaths
		for i in 200:
			await physics_frame
			if is_instance_valid(gm):d=maxi(d,gm.deaths)
			if current_scene and current_scene.get("index")==level+1:break
		ok=ok and d==0 and current_scene and current_scene.get("index")==level+1
		print("ZERO EXIT ",level," ",fighter," ",ok," deaths ",d)
	print("RESULT: ", "PASS" if ok else "FAIL")
	quit(0 if ok else 1)
func pogo_enemy(target,x:float,y:float):
	Input.action_release("jump")
	await tick(2)
	Input.action_press("jump")
	Input.action_press("move_down")
	var pogo_frame=-1
	var previous=0.0
	var start_frame=frame
	var first_jump=-1
	for i in 240:
		if gm.deaths>0: return false
		if not is_instance_valid(target) and pogo_frame<0:return false
		Input.action_release("attack")
		if pogo_frame<0:
			if not pl.is_on_floor() and pl.velocity.y < -250 and first_jump<0:first_jump=frame
			if pl.is_on_floor() and frame-start_frame>8:
				if frame%8==0:Input.action_release("jump")
				if frame%8==2:Input.action_press("jump")
			if initial_dash and first_jump>=0 and frame-first_jump==14 and not pl.is_on_floor():Input.action_press("dash")
			if initial_dash and first_jump>=0 and frame-first_jump==16:Input.action_release("dash")
			steer(target.position.x)
			if frame%2==0 and pl.velocity.y>0 and absf(pl.position.x-target.position.x)<13 and pl.dash_t<=0 and pl.position.y>=target.position.y-(46 if level==1 else 40) and pl.attack_cd<=0:
				Input.action_press("attack")
		else:
			steer(x)
			if frame-pogo_frame==(10 if level==1 else 16):Input.action_press("dash")
			if frame-pogo_frame==(12 if level==1 else 18):Input.action_release("dash")
		await tick()
		if pl.attack_cd>0 and pl.velocity.y<-260 and previous>-240 and pogo_frame<0:
			pogo_frame=frame
		previous=pl.velocity.y
		if pogo_frame>=0 and pl.is_on_floor() and absf(pl.position.y-y)<3 and absf(pl.position.x-x)<5:
			Input.action_release("jump")
			Input.action_release("move_down")
			Input.action_release("dash")
			return true
	return false
