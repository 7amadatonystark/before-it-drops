# ORIGIN: NEW, written by team (AI-assisted). Art: hamster meme drawings supplied by the team.
# GUARD = a rival buyer standing in line for the game. Walks back and forth, hurts on touch.
#   kind "lolli": 2 HP, slow           (lollipop hamster)
#   kind "smug":  3 HP, faster         (smug hamster)
#   kind "flame": 5 HP, hops at you    (flame hamster, elite)
# Hit with the nail or shots; pogo off their heads.
extends Node2D

const Look = preload("res://scripts/look.gd")   # shared outline style

const KILLZONE_SCENE = preload("res://scenes/killzone.tscn")
const STATS := {
	"lolli": {"hp": 2, "speed": 28.0, "height": 22.0, "hop": false},
	"smug": {"hp": 3, "speed": 46.0, "height": 24.0, "hop": false},
	"flame": {"hp": 5, "speed": 34.0, "height": 30.0, "hop": true},
}

var kind := "lolli"
var dir := -1.0
var vel_y := 0.0
var hop_t := 1.5
var sprite: Sprite2D
var ray_wall: RayCast2D
var ray_floor: RayCast2D
var t := 0.0


func _ready() -> void:
	add_to_group("enemy_target")   # bounced-back price tags home in on these
	var s: Dictionary = STATS[kind]
	set_meta("hp", s.hp)
	var tex: Texture2D = load("res://assets/hamsters/%s.png" % kind)
	sprite = Sprite2D.new()
	sprite.texture = tex
	var sc: float = s.height / tex.get_height()
	sprite.scale = Vector2(sc, sc)
	sprite.offset = Vector2(0, -tex.get_height() / 2.0)
	add_child(sprite)
	Look.outline(sprite, 0.8)
	# hurt box (Brackeys killzone) -> touching costs a mask
	var kz = KILLZONE_SCENE.instantiate()
	var shape := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = Vector2(s.height * 0.6, s.height * 0.75)
	shape.shape = r
	shape.position = Vector2(0, -s.height * 0.4)
	kz.add_child(shape)
	add_child(kz)
	ray_wall = RayCast2D.new()
	ray_wall.position = Vector2(0, -6)
	ray_wall.target_position = Vector2(10, 0)
	add_child(ray_wall)
	ray_floor = RayCast2D.new()
	ray_floor.position = Vector2(8, -2)
	ray_floor.target_position = Vector2(0, 10)
	add_child(ray_floor)
	t = randf() * 10.0


func _physics_process(delta: float) -> void:
	if has_meta("dying"):
		return
	t += delta
	var s: Dictionary = STATS[kind]
	ray_wall.target_position.x = 10.0 * dir
	ray_floor.position.x = 8.0 * dir
	var on_ground := vel_y >= 0.0 and ray_floor.is_colliding() or _floor_below()
	if s.hop:
		hop_t -= delta
		var p = _nearest_player()
		if p and hop_t <= 0.0 and _floor_below():
			hop_t = randf_range(1.2, 2.0)
			dir = signf(p.global_position.x - global_position.x)
			vel_y = -230.0
	# turn around at walls and edges
	if ray_wall.is_colliding() or (_floor_below() and not ray_floor.is_colliding() and vel_y >= 0.0):
		dir = -dir
	position.x += dir * s.speed * delta * (1.6 if vel_y < 0.0 else 1.0)
	# simple gravity
	if not _floor_below() or vel_y < 0.0:
		vel_y += 700.0 * delta
		position.y += vel_y * delta
		if vel_y > 0.0 and _floor_below():
			vel_y = 0.0
	sprite.flip_h = dir > 0
	# waddle
	var w := 1.0 + sin(t * 10.0) * 0.06
	var base: float = s.height / sprite.texture.get_height()
	sprite.scale = Vector2(base * w, base / w)


func _floor_below() -> bool:
	var space := get_world_2d().direct_space_state
	var q := PhysicsRayQueryParameters2D.create(global_position + Vector2(0, -2), global_position + Vector2(0, 2))
	q.collision_mask = 1
	return not space.intersect_ray(q).is_empty()


func _nearest_player():
	var best = null
	var bd := 220.0
	for p in get_tree().get_nodes_in_group("player"):
		if p.is_dead:
			continue
		var d: float = p.global_position.distance_to(global_position)
		if d < bd:
			bd = d
			best = p
	return best
