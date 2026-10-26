extends GutTest
## Tunable numbers live in game/data/balance.json, read by the game and the balance simulation alike.


func test_loads_the_game_file() -> void:
	var b := Balance.load_file("res://data/balance.json")
	assert_eq(b.weights.size(), 5)
	assert_gt(b.cooldown, 0.0)
	assert_gt(b.danger_limit, 0.0)


func test_missing_file_gives_defaults() -> void:
	var b := Balance.load_file("res://data/nope.json")
	assert_eq(Array(b.weights), [4, 3, 3, 2, 1])
	assert_eq(b.cooldown, 0.45)
	assert_eq(b.danger_limit, 2.0)
	assert_eq(b.grace, 1.0)


func test_partial_file_keeps_other_defaults() -> void:
	var path := "user://test_balance_%d.json" % randi()
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify({"cooldown": 0.7}))
	f.close()
	var b := Balance.load_file(path)
	assert_eq(b.cooldown, 0.7)
	assert_eq(Array(b.weights), [4, 3, 3, 2, 1])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_spawner_uses_given_weights() -> void:
	var s := Spawner.new(1, PackedInt32Array([0, 0, 1]))
	for i in 50:
		assert_eq(s.take(), 3)


func test_danger_uses_given_limit_and_grace() -> void:
	var d := DangerWatch.new(1.0, 0.5)
	d.update(0.6, {1: 0.6})
	assert_false(d.is_lost())
	d.update(0.5, {1: 1.1})
	assert_true(d.is_lost())


func test_scene_uses_the_balance_file() -> void:
	var main: Node2D = preload("res://scenes/main.tscn").instantiate()
	main.best_path = "user://test_best_bal_%d.cfg" % randi()
	main.settings_path = "user://test_settings_bal_%d.cfg" % randi()
	add_child_autofree(main)
	assert_eq(main.balance.cooldown, Balance.load_file("res://data/balance.json").cooldown)
	for p in [main.best_path, main.settings_path]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
