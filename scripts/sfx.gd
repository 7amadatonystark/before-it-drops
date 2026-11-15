# ORIGIN: NEW, written by team (AI-assisted). Sounds are Kenney's CC0 packs (see CREDITS.md).
# Sfx autoload: Sfx.play("hit") plays a random variant with a little pitch wobble.
extends Node

const DIR := "res://assets/sounds/kenney/"
const SOUNDS := {
	"hit": ["hit_0.ogg", "hit_1.ogg", "hit_2.ogg", "hit_3.ogg", "hit_4.ogg"],
	"smash": ["smash_0.ogg", "smash_1.ogg", "smash_2.ogg"],
	"enemy_down": ["enemy_down.ogg"],
	"parry": ["parry.ogg"],
	"throw": ["throw.wav"],
	"bounced": ["bounced.ogg"],
	"mission_passed": ["mission_passed.ogg"],
	"victory": ["victory.ogg"],
}
var streams := {}
var pool: Array[AudioStreamPlayer] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for k in SOUNDS:
		var arr: Array = []
		for f in SOUNDS[k]:
			var s = load(DIR + f)
			if s:
				arr.append(s)
		streams[k] = arr
	for i in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		pool.append(p)


func play(name: String, db := 0.0, wobble := 0.08) -> void:
	var arr: Array = streams.get(name, [])
	if arr.is_empty():
		return
	var p: AudioStreamPlayer = null
	for q in pool:
		if not q.playing:
			p = q
			break
	if p == null:
		p = pool[0]
	p.stream = arr.pick_random()
	p.volume_db = db
	p.pitch_scale = 1.0 + randf_range(-wobble, wobble)
	p.play()
