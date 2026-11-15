# ORIGIN: NEW, written by team (AI-assisted).
# RAID CAMERA (Brawlhalla style): one shared screen. Follows the middle of every player AND the boss,
# and zooms out when they spread apart so everyone stays on screen.
extends Camera2D

const MAX_ZOOM := 3.0      # closest
const MIN_ZOOM := 1.6      # furthest out
const MARGIN := Vector2(90, 70)

var arena_rect := Rect2(0, -240, 640, 300)


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 4.0
	limit_left = int(arena_rect.position.x)
	limit_right = int(arena_rect.end.x)
	limit_top = int(arena_rect.position.y)
	limit_bottom = int(arena_rect.end.y)
	make_current()


func _process(delta: float) -> void:
	var pts: Array = []
	for p in get_tree().get_nodes_in_group("player"):
		if not p.is_dead:
			pts.append(p.global_position + Vector2(0, -16))
	for b in get_tree().get_nodes_in_group("raid_focus"):   # the boss
		if not b.get("dead"):
			pts.append(b.global_position + Vector2(0, -30))
	if pts.is_empty():
		return
	var box := Rect2(pts[0], Vector2.ZERO)
	for pt in pts:
		box = box.expand(pt)
	box = box.grow_individual(MARGIN.x, MARGIN.y, MARGIN.x, MARGIN.y)
	global_position = box.get_center()
	var view := get_viewport_rect().size
	var z := minf(view.x / box.size.x, view.y / box.size.y)
	z = clampf(z, MIN_ZOOM, MAX_ZOOM)
	zoom = zoom.lerp(Vector2(z, z), 1.0 - exp(-3.0 * delta))
