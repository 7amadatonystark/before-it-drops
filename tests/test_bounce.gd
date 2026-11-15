# ORIGIN: NEW, test script written by team (AI-assisted).
# Headless test: die -> body appears -> respawn -> fall onto body -> bounce.
# Run: godot --headless -s tests/test_bounce.gd
extends SceneTree

func _initialize():
	change_scene_to_file("res://scenes/game.tscn")

var f := 0
var gm
var pl
var bounced := false
var body_pos := Vector2.ZERO

func _physics_process(_d):
	f += 1
	if f == 10:
		gm = get_first_node_in_group("game_manager")
		pl = get_first_node_in_group("player")
		print("start player at ", pl.global_position, " respawn ", gm.respawn_point)
		gm.player_died(true)
	if f == 80:
		print("deaths=", gm.deaths, " bodies=", gm.bodies.size(), " player back at ", pl.global_position, " controllable=", pl.controllable)
		body_pos = gm.bodies[0].global_position
		pl.global_position = body_pos + Vector2(0, -60)   # drop onto the body
		pl.velocity = Vector2.ZERO
	if f > 10 and f < 200 and pl and pl.velocity.y < -350.0 and not bounced:
		bounced = true
		print("BOUNCE OK at frame ", f, " vy=", pl.velocity.y)
	if f == 200:
		print("RESULT: ", "PASS" if (bounced and gm.deaths == 1 and gm.bodies.size() == 1) else "FAIL")
		quit()
	return false
