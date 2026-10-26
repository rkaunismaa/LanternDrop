extends GutTest
## The physics scene: dropping, merging, losing, restarting.

const MainScene := preload("res://scenes/main.tscn")
var main: Node2D


func before_each() -> void:
	main = MainScene.instantiate()
	main.best_path = "user://test_best_scene_%d.cfg" % randi()
	main.settings_path = "user://test_settings_scene_%d.cfg" % randi()
	add_child_autofree(main)
	main.start(5)


func after_each() -> void:
	Engine.time_scale = 1.0
	DirAccess.remove_absolute(ProjectSettings.globalize_path(main.best_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(main.settings_path))


func test_starts_empty_with_a_preview() -> void:
	assert_eq(main.score, 0)
	assert_eq(main.lanterns().size(), 0)
	assert_between(main.spawner.peek(), 1, 5)
	assert_false(main.is_over)


func test_drop_spawns_the_previewed_kind_then_cooldown() -> void:
	var kind: int = main.spawner.peek()
	var l: Lantern = main.drop_at(360.0)
	assert_not_null(l)
	assert_eq(l.kind, kind)
	assert_null(main.drop_at(360.0), "cooldown blocks an instant second drop")


func test_aim_stays_inside_the_jar() -> void:
	main.aim(-500.0)
	assert_gte(main.aim_x, main.JAR_LEFT + LanternKinds.radius(main.spawner.peek()))
	main.aim(5000.0)
	assert_lte(main.aim_x, main.JAR_RIGHT - LanternKinds.radius(main.spawner.peek()))


func test_two_of_a_kind_merge_and_score() -> void:
	var y: float = main.JAR_FLOOR - 40.0
	main.spawn_lantern(3, Vector2(330, y))
	main.spawn_lantern(3, Vector2(330 + 2 * LanternKinds.radius(3) - 2, y))
	await wait_until(func() -> bool: return main.lanterns().size() == 1, 3.0)
	assert_eq(main.lanterns().size(), 1)
	assert_eq((main.lanterns()[0] as Lantern).kind, 4)
	assert_eq(main.score, LanternKinds.points(4))


func test_different_kinds_stay_apart() -> void:
	var y: float = main.JAR_FLOOR - 40.0
	main.spawn_lantern(2, Vector2(300, y))
	main.spawn_lantern(3, Vector2(300 + LanternKinds.radius(2) + LanternKinds.radius(3) - 2, y))
	await wait_physics_frames(30)
	assert_eq(main.lanterns().size(), 2)


func test_three_touching_merge_only_once() -> void:
	var y: float = main.JAR_FLOOR - 30.0
	var r := LanternKinds.radius(2)
	for i in 3:
		main.spawn_lantern(2, Vector2(300 + i * (2 * r - 2), y))
	await wait_physics_frames(60)
	var kinds: Array = main.lanterns().map(func(l: Lantern) -> int: return l.kind)
	kinds.sort()
	assert_eq(kinds, [2, 3], "one pair merges; the third lantern stays")


func test_two_suns_vanish_for_a_bonus() -> void:
	# Two Suns don't fit side by side (552 px in a 520 px jar), so stack them.
	var r := LanternKinds.radius(11)
	main.spawn_lantern(11, Vector2(360, main.JAR_FLOOR - r))
	main.spawn_lantern(11, Vector2(360, main.JAR_FLOOR - 3 * r + 2))
	await wait_until(func() -> bool: return main.score == MergeRules.SUN_BONUS, 3.0)
	assert_eq(main.lanterns().size(), 0)
	assert_eq(main.score, MergeRules.SUN_BONUS)


func test_overflow_ends_the_night() -> void:
	Engine.time_scale = 4.0
	var l: Lantern = main.spawn_lantern(5, Vector2(360, main.DANGER_Y - 60))
	l.freeze = true  # hold it above the line
	l.age = 5.0
	await wait_until(func() -> bool: return main.is_over, 3.0)
	assert_true(main.is_over)
	assert_true(main.get_node("%GameOver").visible)
	assert_null(main.drop_at(360.0), "no drops after the night ends")


func test_restart_clears_the_jar() -> void:
	main.spawn_lantern(4, Vector2(360, main.JAR_FLOOR - 50))
	main.score = 42
	main.start(9)
	await wait_physics_frames(2)
	assert_eq(main.lanterns().size(), 0)
	assert_eq(main.score, 0)
	assert_false(main.get_node("%GameOver").visible)


func test_best_score_is_kept_when_the_night_ends() -> void:
	main.score = 77
	main.end_night()
	assert_eq(main.best.best, 77)
	assert_string_contains(main.get_node("%GameOverText").text, "77")


func test_lantern_dropped_against_a_wall_still_falls() -> void:
	# Found while playing: a lantern dropped flush with the glass stuck there by friction and ended the night.
	for edge in [-5000.0, 5000.0]:
		main.start(5)
		var l: Lantern = main.drop_at(edge)
		await wait_seconds(1.2)
		assert_gt(l.position.y, main.DANGER_Y + 100, "a lantern at the %s wall must fall" % ("left" if edge < 0 else "right"))


# --- painted backdrop ---

func test_painted_backdrop_is_used() -> void:
	var bg: Sprite2D = main.get_node("%Backdrop")
	assert_true(bg.visible)
	assert_eq(bg.texture.resource_path, "res://art/backdrop.png")
	var size: Vector2 = bg.texture.get_size() * bg.scale
	assert_gte(size.x, 720.0, "the painting covers the screen width")
	assert_gte(size.y, 1080.0, "the painting covers the screen height")


func test_missing_art_falls_back_to_the_drawn_sky() -> void:
	main.art_dir = "res://no_art/"
	main.apply_art()
	assert_false(main.get_node("%Backdrop").visible)



# --- sound effects ---

func test_drop_plays_a_sound() -> void:
	main.drop_at(360.0)
	assert_has(main.sfx.history, "drop")


func test_merge_plays_the_chime_for_the_new_kind() -> void:
	var y: float = main.JAR_FLOOR - 40.0
	main.spawn_lantern(3, Vector2(330, y))
	main.spawn_lantern(3, Vector2(330 + 2 * LanternKinds.radius(3) - 2, y))
	await wait_until(func() -> bool: return main.sfx.history.has("merge_4"), 3.0)
	assert_has(main.sfx.history, "merge_4")


func test_two_suns_play_the_sun_sound() -> void:
	var r := LanternKinds.radius(11)
	main.spawn_lantern(11, Vector2(360, main.JAR_FLOOR - r))
	main.spawn_lantern(11, Vector2(360, main.JAR_FLOOR - 3 * r + 2))
	await wait_until(func() -> bool: return main.sfx.history.has("sun"), 3.0)
	assert_has(main.sfx.history, "sun")


func test_landing_makes_a_sound() -> void:
	var l: Lantern = main.spawn_lantern(5, Vector2(360, main.JAR_FLOOR - 300))
	await wait_until(func() -> bool: return main.sfx.history.has("land"), 3.0)
	assert_has(main.sfx.history, "land")


func test_game_over_and_danger_sounds() -> void:
	Engine.time_scale = 4.0
	var l: Lantern = main.spawn_lantern(5, Vector2(360, main.DANGER_Y - 60))
	l.freeze = true
	l.age = 5.0
	await wait_until(func() -> bool: return main.is_over, 3.0)
	assert_has(main.sfx.history, "danger", "a warning pulse before the end")
	assert_has(main.sfx.history, "game_over")


func test_m_key_toggles_mute() -> void:
	var press := InputEventKey.new()
	press.physical_keycode = KEY_M
	press.pressed = true
	main._unhandled_input(press)
	assert_true(main.sfx.muted)
	assert_string_contains(main.get_node("%SoundToggle").text, "off")
	main._unhandled_input(press)
	assert_false(main.sfx.muted)
