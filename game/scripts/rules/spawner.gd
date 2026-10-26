class_name Spawner
extends RefCounted
## Picks which lantern is dropped next: only kinds 1-5, weighted 4,3,3,2,1. Seeded, so runs repeat in tests.

const WEIGHTS: PackedInt32Array = [4, 3, 3, 2, 1]

var _rng := RandomNumberGenerator.new()
var _next: int


func _init(seed: int) -> void:
	_rng.seed = seed
	_next = _roll()


## The lantern that will be dropped next (shown as the preview).
func peek() -> int:
	return _next


## Take the next lantern and roll the one after it.
func take() -> int:
	var k := _next
	_next = _roll()
	return k


func _roll() -> int:
	var total := 0
	for w in WEIGHTS:
		total += w
	var r := _rng.randi_range(1, total)
	for i in WEIGHTS.size():
		r -= WEIGHTS[i]
		if r <= 0:
			return i + 1
	return WEIGHTS.size()
