class_name Sfx
extends Node
## Plays the game's sounds (from SoundBank) through a small pool of players, so they can overlap.
## Mute is the player's choice and is saved between sessions.

const VOICES := 8

var settings_path := "user://settings.cfg"
var muted := false
var history: Array[String] = []  ## recent sounds, newest last (tests read this)

var _bank: Dictionary
var _players: Array[AudioStreamPlayer] = []
var _next := 0


func _ready() -> void:
	_bank = SoundBank.build()
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	var cfg := ConfigFile.new()
	if cfg.load(settings_path) == OK:
		muted = bool(cfg.get_value("sound", "muted", false))


func play(sound: String, volume_db := 0.0, pitch := 1.0) -> void:
	if muted or not _bank.has(sound):
		return
	var p := _free_player()
	p.stream = _bank[sound]
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.play()
	history.append(sound)
	if history.size() > 50:
		history.remove_at(0)


func set_muted(on: bool) -> void:
	muted = on
	if on:
		for p in _players:
			p.stop()
	var cfg := ConfigFile.new()
	cfg.load(settings_path)
	cfg.set_value("sound", "muted", on)
	cfg.save(settings_path)


func _free_player() -> AudioStreamPlayer:
	for p in _players:
		if not p.playing:
			return p
	_next = (_next + 1) % _players.size()  # all busy: reuse the oldest-ish voice
	return _players[_next]
