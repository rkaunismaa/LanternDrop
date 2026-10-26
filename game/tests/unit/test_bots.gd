extends GutTest
## The balance simulation's bots, and the run stats the game keeps for them.

const MainScene := preload("res://scenes/main.tscn")
var main: Node2D


func before_each() -> void:
	main = MainScene.instantiate()
	main.best_path = "user://test_best_bots_%d.cfg" % randi()
	main.settings_path = "user://test_settings_bots_%d.cfg" % randi()
	add_child_autofree(main)
	main.start(5)


func after_each() -> void:
	for p in [main.best_path, main.settings_path]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(p))


func test_landing_height_on_an_empty_floor() -> void:
	var y := SimBots.landing_y(main, 360.0, 3)
	assert_almost_eq(y, main.JAR_FLOOR - LanternKinds.radius(3), 0.01)


func test_landing_height_on_top_of_a_lantern() -> void:
	var l: Lantern = main.spawn_lantern(5, Vector2(360, main.JAR_FLOOR - LanternKinds.radius(5)))
	l.freeze = true
	var y := SimBots.landing_y(main, 360.0, 2)
	assert_almost_eq(y, l.position.y - LanternKinds.radius(5) - LanternKinds.radius(2), 0.01)


func test_careful_bot_aims_at_a_matching_lantern() -> void:
	var kind: int = main.spawner.peek()
	var match_l: Lantern = main.spawn_lantern(kind, Vector2(500, main.JAR_FLOOR - LanternKinds.radius(kind)))
	match_l.freeze = true
	var other := 5 if kind != 5 else 4
	var block: Lantern = main.spawn_lantern(other, Vector2(220, main.JAR_FLOOR - LanternKinds.radius(other)))
	block.freeze = true
	var x := SimBots.careful_x(main)
	assert_eq(SimBots.landing(main, x, kind)[1], match_l, "comes to rest on its twin, so they merge")


func test_random_bot_stays_inside_the_jar() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in 100:
		var x := SimBots.random_x(main, rng)
		assert_between(x, main.JAR_LEFT, main.JAR_RIGHT)


func test_game_tracks_biggest_kind_and_suns() -> void:
	assert_eq(main.biggest_kind, 0)
	var y: float = main.JAR_FLOOR - 40.0
	main.spawn_lantern(3, Vector2(330, y))
	main.spawn_lantern(3, Vector2(330 + 2 * LanternKinds.radius(3) - 2, y))
	await wait_until(func() -> bool: return main.biggest_kind == 4, 3.0)
	assert_eq(main.biggest_kind, 4)
	assert_eq(main.suns, 0)
	main.start(6)
	assert_eq(main.biggest_kind, 0, "a new night resets the stats")
