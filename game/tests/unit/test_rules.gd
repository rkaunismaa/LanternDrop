extends GutTest
## Lantern Drop's rules, as in docs/design.md.


func test_eleven_kinds_growing() -> void:
	assert_eq(LanternKinds.COUNT, 11)
	assert_eq(LanternKinds.radius(1), 18.0)
	assert_eq(LanternKinds.radius(11), 138.0)
	for t in range(1, 11):
		assert_gt(LanternKinds.radius(t + 1), LanternKinds.radius(t))
	assert_eq(LanternKinds.name_of(1), "Ember")
	assert_eq(LanternKinds.name_of(11), "Sun")


func test_points_for_making_a_kind() -> void:
	assert_eq(LanternKinds.points(2), 3)
	assert_eq(LanternKinds.points(5), 15)
	assert_eq(LanternKinds.points(11), 66)


func test_every_kind_has_a_color() -> void:
	var seen := {}
	for t in range(1, 12):
		var c := LanternKinds.color(t)
		assert_false(seen.has(c), "kind %d repeats a colour" % t)
		seen[c] = true


func test_merge_two_of_a_kind() -> void:
	var r := MergeRules.result(3, 3)
	assert_true(r.merge)
	assert_eq(r.kind, 4)
	assert_eq(r.points, 10)
	assert_false(r.vanish)


func test_different_kinds_do_not_merge() -> void:
	assert_false(MergeRules.result(3, 4).merge)


func test_two_suns_vanish_for_a_bonus() -> void:
	var r := MergeRules.result(11, 11)
	assert_true(r.merge)
	assert_true(r.vanish)
	assert_eq(r.points, 100)


func test_spawner_drops_only_small_kinds_with_weights() -> void:
	var s := Spawner.new(7)
	var counts := {}
	for i in 10000:
		var k := s.take()
		assert_between(k, 1, 5)
		counts[k] = int(counts.get(k, 0)) + 1
	# weights 4,3,3,2,1 out of 13
	assert_almost_eq(counts[1] / 10000.0, 4.0 / 13.0, 0.02)
	assert_almost_eq(counts[5] / 10000.0, 1.0 / 13.0, 0.02)


func test_spawner_shows_next_and_is_seeded() -> void:
	var a := Spawner.new(3)
	var b := Spawner.new(3)
	for i in 50:
		var next := a.peek()
		assert_eq(a.take(), next)
		assert_eq(b.take(), next)


func test_danger_needs_two_seconds_in_a_row() -> void:
	var d := DangerWatch.new()
	d.update(1.5, {1: 5.0})
	assert_false(d.is_lost())
	d.update(0.6, {1: 5.0})
	assert_true(d.is_lost())


func test_danger_resets_when_lantern_drops_below() -> void:
	var d := DangerWatch.new()
	d.update(1.5, {1: 5.0})
	d.update(0.1, {})
	d.update(1.5, {1: 5.0})
	assert_false(d.is_lost())


func test_danger_ignores_freshly_dropped_lanterns() -> void:
	var d := DangerWatch.new()
	d.update(3.0, {1: 0.5})  # dropped half a second ago: still falling in
	assert_false(d.is_lost())


func test_danger_level_for_the_warning_glow() -> void:
	var d := DangerWatch.new()
	assert_eq(d.level(), 0.0)
	d.update(1.0, {1: 5.0})
	assert_almost_eq(d.level(), 0.5, 0.001)


func test_best_score_is_saved_and_only_goes_up() -> void:
	var path := "user://test_best_%d.cfg" % randi()
	var b := BestScore.new(path)
	assert_eq(b.best, 0)
	assert_true(b.submit(120))
	assert_false(b.submit(80))
	assert_eq(BestScore.new(path).best, 120)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
