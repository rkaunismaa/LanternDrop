class_name BestScore
extends RefCounted
## The best score, kept between sessions.

var best := 0
var _path: String


func _init(path: String = "user://best.cfg") -> void:
	_path = path
	var cfg := ConfigFile.new()
	if cfg.load(_path) == OK:
		best = int(cfg.get_value("score", "best", 0))


## Record a finished night's score. Returns true if it is a new best.
func submit(score: int) -> bool:
	if score <= best:
		return false
	best = score
	var cfg := ConfigFile.new()
	cfg.set_value("score", "best", best)
	cfg.save(_path)
	return true
