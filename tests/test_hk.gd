# ORIGIN: NEW, test script written by team (AI-assisted).
# Tests the Hollow Knight-style systems. Run: godot --headless -s tests/test_hk.gd
extends SceneTree

func _initialize():
	change_scene_to_file("res://scenes/game.tscn")

var f := 0
var gm
var pl
var slime
var ok := {}
var stage := 0

func _physics_process(_d):
	f += 1
	if f == 10:
		gm = get_first_node_in_group("game_manager")
		pl = get_first_node_in_group("player")
		slime = current_scene.get_node("Slime")
		gm.score = 7
		gm.player_hit(pl.global_position + Vector2(10, 0))
		ok["mask_lost"] = gm.masks == 4
	if f == 80:   # finish off masks -> death -> body holds 7 geo
		for i in 4:
			pl.invuln = 0.0
			gm.player_hit(pl.global_position)
	if f == 140:
		ok["died_once"] = gm.deaths == 1
		ok["body_has_geo"] = gm.bodies.size() == 1 and gm.bodies[0].geo == 7
		ok["masks_refilled"] = gm.masks == 5
		ok["geo_dropped"] = gm.score == 0
		# stand next to the body and slash it
		var b = gm.bodies[0]
		pl.global_position = b.global_position + Vector2(-14, 0)
		pl.facing = 1
		pl.attack_cd = 0.0
		pl._attack()
		ok["geo_reclaimed"] = gm.score == 7 and b.geo == 0
	if f == 160:
		# POGO: put the player just above the slime, falling, and down-slash
		pl.global_position = slime.global_position + Vector2(0, -30)
		pl.velocity = Vector2(0, 0)
		pl.invuln = 1.0
	if f == 166:
		print("on_floor=", pl.is_on_floor(), " dy=", pl.global_position.y - slime.global_position.y)
		Input.action_press("move_down")
		pl.attack_cd = 0.0
		pl._attack()
		Input.action_release("move_down")
		ok["pogo"] = is_equal_approx(pl.velocity.y, pl.POGO_VELOCITY)
	if f == 175:
		pl.global_position = slime.global_position + Vector2(0, -30)
		pl.velocity = Vector2.ZERO
		pl.invuln = 1.0
	if f == 181:
		Input.action_press("move_down")
		pl.attack_cd = 0.0
		pl._attack()
		Input.action_release("move_down")
	if f == 190:
		var kz = load("res://scenes/killzone.tscn").instantiate()
		kz.instant_kill = true
		var shape := CollisionShape2D.new()
		var r := RectangleShape2D.new(); r.size = Vector2(40, 40); shape.shape = r
		kz.add_child(shape)
		current_scene.add_child(kz)
		kz.global_position = pl.global_position
		pl.invuln = 0.0
		ok["_deaths_before"] = true
		set_meta("d0", gm.deaths)
	if f == 199:
		ok["instant_kill"] = gm.deaths == get_meta("d0") + 1
	if f == 230:
		ok["enemy_killed"] = not is_instance_valid(slime) or slime.is_queued_for_deletion()
		var all_ok := true
		for k in ok:
			print(k, ": ", ok[k])
			all_ok = all_ok and ok[k]
		print("RESULT: ", "PASS" if all_ok else "FAIL")
		quit()
	return false
