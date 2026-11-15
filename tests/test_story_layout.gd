# ORIGIN: NEW, written by team (AI-assisted).
# Catch unsupported enemy placements in the actual generated collision map.
# Run with Godot 4.3: godot --headless -s tests/test_story_layout.gd
extends SceneTree

const Levels = preload("res://scripts/levels.gd")
var failures := 0

func _initialize():
	call_deferred("_run")

func _run():
	for index in Levels.LEVELS.size():
		Engine.set_meta("level_index", index + 1)
		change_scene_to_file("res://scenes/story_level.tscn")
		await process_frame
		await physics_frame
		await physics_frame
		var space = current_scene.get_world_2d().direct_space_state
		for child in current_scene.get_children():
			if child.get_script() not in [preload("res://scripts/rival.gd"), preload("res://scripts/guard.gd")]:
				continue
			var q = PhysicsRayQueryParameters2D.create(child.global_position + Vector2(0, -2), child.global_position + Vector2(0, 4), 1)
			if space.intersect_ray(q).is_empty():
				failures += 1
				print("FAIL: level %d %s has no ground at %s" % [index + 1, child.kind, child.global_position])
	print("RESULT: ", "PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
