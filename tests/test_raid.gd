# ORIGIN: NEW, test script written by team (AI-assisted).
# Co-op BOSS RAID test: 3 players spawn, take separate damage, a dead player's body bounces a teammate.
extends SceneTree

func _initialize():
	Engine.set_meta("raid", [{"device": -2, "char": "spark"}, {"device": 0, "char": "zoom"}, {"device": 1, "char": "brains"}])
	change_scene_to_file("res://scenes/boss_arena.tscn")

var f := 0
var ok := {}
var gm
var ps: Array = []

var wait := 0

func _physics_process(_d):
	# wait until the raid has spawned all 3 players (load time varies)
	if f == 0:
		wait += 1
		gm = get_first_node_in_group("game_manager")
		if (gm == null or gm.players.size() < 3) and wait < 120:
			return
		f = 9
	f += 1
	if f == 10:
		gm = get_first_node_in_group("game_manager")
		ps = gm.players
		ok["three_players"] = ps.size() == 3
		ok["chars"] = ps.size() == 3 and ps[0].char_id == "spark" and ps[1].char_id == "zoom" and ps[2].char_id == "brains"
		ok["brains_6_masks"] = ps.size() == 3 and ps[2].pmax == 6
		ok["shared_camera"] = get_root().get_camera_2d() != null and get_root().get_camera_2d().get_script() != null
		ok["own_inputs"] = InputMap.has_action("p0_jump") and InputMap.has_action("kb_attack")
		gm.player_hit(ps[1].global_position + Vector2(10, 0), false, ps[1])
		ok["separate_masks"] = ps[0].pmasks == ps[0].pmax and ps[1].pmasks == ps[1].pmax - 1
	if f == 40:
		for i in 6:
			ps[1].invuln = 0.0
			gm.player_hit(ps[1].global_position, false, ps[1])
	if f == 120:
		ok["p2_body"] = gm.bodies.size() == 1
		ok["p1_alive"] = not ps[0].is_dead
		# P1 drops onto P2's body
		ps[0].global_position = gm.bodies[0].global_position + Vector2(0, -40)
		ps[0].velocity = Vector2.ZERO
	if f > 120 and f < 200 and ps[0].velocity.y < -350:
		ok["teammate_bounce"] = true
	if f == 190:
		ok["p2_back"] = not ps[1].is_dead and ps[1].pmasks == ps[1].pmax
	if f == 200:
		ok["teammate_bounce"] = ok.get("teammate_bounce", false)
		var all_ok := true
		for k in ok:
			print(k, ": ", ok[k])
			all_ok = all_ok and ok[k]
		print("RESULT: ", "PASS" if all_ok else "FAIL")
		Engine.set_meta("raid", [])
		quit()
	return false
