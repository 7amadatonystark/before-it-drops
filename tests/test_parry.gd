# ORIGIN: NEW, test script written by team (AI-assisted).
# Tests BOUNCE IT BACK: strike the Godfather's price tag and it breaks his armor.
# Run: godot --headless -s tests/test_parry.gd
extends SceneTree

const EnemyShot = preload("res://scripts/enemy_shot.gd")

func _initialize():
	change_scene_to_file("res://scenes/boss_arena.tscn")

var f := 0
var pl
var boss
var shot
var hp0 := 0
var ok := {}

func _physics_process(_d):
	f += 1
	if f == 20:
		pl = get_first_node_in_group("player")
		for n in get_nodes_in_group("enemy_target"):
			if n.get("MAX_HP") != null:
				boss = n
		ok["boss_found"] = boss != null
		if boss == null:
			return
		hp0 = boss.hp
		boss.state = "idle"
		boss.state_t = 99.0
		pl.global_position = boss.global_position + Vector2(-150, 0)
		pl.facing = 1
		shot = EnemyShot.new()
		pl.get_parent().add_child(shot)
		shot.global_position = pl.global_position + Vector2(16, -8)
		shot.velocity = Vector2(-40, 0)
		pl.attack_cd = 0.0
		pl._attack()
		ok["reflected"] = shot.reflected
	if f == 90 and boss:
		ok["boss_damaged"] = boss.hp < hp0
		ok["shot_gone"] = not is_instance_valid(shot)
		var all := ok.values().all(func(v): return v)
		print(ok)
		print("RESULT: ", "PASS" if all else "FAIL")
		quit()
	if f > 95:
		quit()
