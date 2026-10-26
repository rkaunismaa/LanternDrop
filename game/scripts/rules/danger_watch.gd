class_name DangerWatch
extends RefCounted
## The night ends when a settled lantern stays above the danger line for `limit` seconds in a row.

var limit: float
var grace: float  ## lanterns younger than this are still falling in and don't count
var _time_above := 0.0


func _init(p_limit := 2.0, p_grace := 1.0) -> void:
	limit = p_limit
	grace = p_grace


## above: lantern id -> age in seconds, for every lantern currently above the danger line.
func update(delta: float, above: Dictionary) -> void:
	var settled := false
	for id in above:
		if float(above[id]) >= grace:
			settled = true
	_time_above = _time_above + delta if settled else 0.0


func is_lost() -> bool:
	return _time_above >= limit


## 0 (safe) to 1 (lost): drives the warning glow on the rim.
func level() -> float:
	return clampf(_time_above / limit, 0.0, 1.0)


func reset() -> void:
	_time_above = 0.0
