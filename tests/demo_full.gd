# ORIGIN: NEW, demo-recording script (AI-assisted). Plays the whole game automatically for the trailer:
# title -> story intro -> fighter select -> co-op lobby -> Levels 1-3 with 3 players -> the Godfather -> ending.
# Record: godot --path . -s tests/demo_full.gd --write-movie out.avi --fixed-fps 60
# (timings below are in 30 fps 'beats'; movement runs every 60 fps physics tick so it's smooth)
extends SceneTree

var phase := ""
var t := 0          # beats (1/30 s) in this phase
var tick := 0
var beat := false
var gm
var target
var target_t := 0
var level_frames := {1: 700, 2: 560, 3: 640}
var walk_t := 0
const Levels = preload("res://scripts/levels.gd")


func _initialize():
	_go("menu", "res://scenes/menu.tscn")


func _go(p: String, scene: String) -> void:
	phase = p
	t = 0
	gm = null
	target = null
	change_scene_to_file(scene)


func _key(code: int) -> void:
	var e := InputEventKey.new()
	e.keycode = code
	e.physical_keycode = code
	e.pressed = true
	Input.parse_input_event(e)
	var r := e.duplicate()
	r.pressed = false
	Input.parse_input_event(r)


func _physics_process(_d):
	tick += 1
	beat = tick % 2 == 0
	if beat:
		t += 1
	if not beat and phase != "level" and phase != "boss":
		return
	match phase:
		"menu":
			if t == 80:
				_go("intro", "res://scenes/intro.tscn")
		"intro":
			if t in [70, 75, 130, 135, 190, 195]:
				_key(KEY_SPACE)
			if t == 230:
				_go("select", "res://scenes/character_select.tscn")
		"select":
			if t in [40, 70, 100]:
				_key(KEY_RIGHT)
			if t == 130:
				_key(KEY_LEFT)
			if t == 160:
				phase = "lobby"
				t = 0
				_key(KEY_R)
		"lobby":
			var lobby = current_scene
			if lobby == null or not lobby.has_method("_join"):
				return
			if t == 30: lobby._join(-2)
			if t == 55: lobby._join(0)
			if t == 70: lobby._cycle(0, 1)
			if t == 85: lobby._join(1)
			if t == 100: lobby._cycle(1, 1)
			if t == 115: lobby._cycle(1, 1)
			if t == 150:
				lobby._start()
				phase = "level"
				t = -20
		"level", "boss":
			_fight()
		"ending":
			if t == 330:
				quit()


func _fight() -> void:
	if t < 1:
		return
	if gm == null or not is_instance_valid(gm):
		gm = get_first_node_in_group("game_manager")
		if gm == null:
			return
	var ps: Array = gm.players.filter(func(p): return is_instance_valid(p))
	if ps.size() < 3:
		return
	for p in ps:
		p.invuln = maxf(p.invuln, 0.5)      # demo players don't die (except on purpose)
	var lvl: int = int(Engine.get_meta("level_index", 1))
	# one on-purpose death in Level 1: P3's body becomes a trampoline
	if phase == "level" and lvl == 1 and t < 150:
		if not beat:
			return
		if t == 30:
			ps[2].invuln = 0.0
			gm.player_died(true, ps[2])
		if t == 70 and gm.bodies.size() > 0:   # P1 drops onto P3's body -> BOUNCE
			ps[0].global_position = gm.bodies[0].global_position + Vector2(0, -50)
			ps[0].velocity = Vector2.ZERO
		return
	# pick the closest enemy still standing
	# bosses only take hits from above: if the fight stalls, P2 lands a pogo on the head
	if beat and target and is_instance_valid(target) and target.get("MAX_HP") != null and target.get("dead") != true and target_t > 80:
		ps[1].global_position = target.global_position + Vector2(0, -130)
		ps[1].velocity = Vector2.ZERO
		target.on_nail_hit(ps[1])
		target_t = 0
	if beat and (target == null or not is_instance_valid(target) or target.has_meta("dying") or target.get("dead") == true or target_t > 170):
		if target and is_instance_valid(target) and target_t > 170 and not target.has_meta("dying"):
			if target.has_method("on_nail_hit") and target.get("MAX_HP") == null:
				gm.damage_enemy(target, ps[1])
		target = null
		target_t = 0
		var bd := INF
		for e in get_nodes_in_group("enemy_target"):
			if not is_instance_valid(e) or e.has_meta("dying") or e.get("dead") == true:
				continue
			var d: float = e.global_position.distance_to(ps[0].global_position)
			if d < bd:
				bd = d
				target = e
	if target == null or not is_instance_valid(target):
		_walk_to_exit(ps, lvl)
		return
	if beat:
		target_t += 1
	var tp: Vector2 = target.global_position
	var spots := [tp + Vector2(-26, -2), tp + Vector2(0, -56), tp + Vector2(26, -2)]
	if target.get("MAX_HP") != null:          # the Godfather is big
		spots = [tp + Vector2(-46, -2), tp + Vector2(0, -100), tp + Vector2(46, -2)]
	for i in 3:
		var p = ps[i]
		if p.is_dead:
			continue
		var to: Vector2 = spots[i] - p.global_position
		p.velocity = to.normalized() * minf(to.length() * 7.0, 150.0)   # glide through physics = smooth
		p.facing = 1 if i == 0 else (-1 if i == 2 else p.facing)
		if beat and to.length() < 10.0:
			var every: int = [24, 32, 28][i]
			if (t + i * 5) % every == 0:
				p.attack_cd = 0.0
				if i == 1:
					Input.action_press("p0_move_down")
					p._attack()
					Input.action_release("p0_move_down")
				else:
					p._attack()
	var limit: int = level_frames.get(lvl, 500)
	if phase == "level" and t > limit:
		_next_scene()
	if phase == "boss" and target and is_instance_valid(target) and target.get("dead") == true:
		pass


func _next_scene() -> void:
	if phase == "boss":
		# the Godfather fell: let the ending play
		phase = "ending"
		t = 0
		return
	var lvl: int = int(Engine.get_meta("level_index", 1))
	if lvl < 3:
		Engine.set_meta("level_index", lvl + 1)
		_go("level", "res://scenes/story_level.tscn")
	else:
		_go("boss", "res://scenes/boss_arena.tscn")


func _walk_to_exit(ps: Array, lvl: int) -> void:
	if phase == "boss":
		# wait between the Godfather and THE VICE QUEEN; only finish once the ending is playing
		var ending_on: bool = current_scene.get_children().any(func(c): return c.get_script() and c.get_script().resource_path.ends_with("ending.gd"))
		if ending_on:
			_next_scene()
		return
	if beat:
		walk_t += 1
	var rows: Array = Levels.LEVELS[lvl - 1].map
	var ex := Vector2.ZERO
	for y in rows.size():
		var x: int = rows[y].find("E")
		if x >= 0:
			ex = Vector2(x * 16 + 8, (y + 1) * 16 - 2)
	for i in ps.size():
		var p = ps[i]
		var to: Vector2 = ex + Vector2(i * 14 - 14, 0) - p.global_position
		p.velocity = to.normalized() * minf(to.length() * 6.0, 130.0)
		p.facing = 1 if to.x >= 0 else -1
	if walk_t > 110:
		walk_t = 0
		_next_scene()
