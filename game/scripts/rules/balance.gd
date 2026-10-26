class_name Balance
extends RefCounted
## The tunable numbers (game/data/balance.json), shared by the game and the balance simulation.
## Anything missing from the file keeps its default.

var weights := PackedInt32Array([4, 3, 3, 2, 1])  ## drop chances for kinds 1..n
var cooldown := 0.45  ## seconds between drops
var danger_limit := 2.0  ## seconds above the line before the night ends
var grace := 1.0  ## fresh drops younger than this don't count as overflowing


static func load_file(path: String) -> Balance:
	var b := Balance.new()
	if not FileAccess.file_exists(path):
		return b
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(data) != TYPE_DICTIONARY:
		return b
	if data.has("weights"):
		b.weights = PackedInt32Array(data.weights.map(func(w: Variant) -> int: return int(w)))
	b.cooldown = float(data.get("cooldown", b.cooldown))
	b.danger_limit = float(data.get("danger_limit", b.danger_limit))
	b.grace = float(data.get("grace", b.grace))
	return b
