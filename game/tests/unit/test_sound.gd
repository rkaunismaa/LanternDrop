extends GutTest
## Sounds are generated in code (SoundBank) and played through Sfx. Headless runs use Godot's dummy audio driver.


func test_bank_has_every_sound() -> void:
	var bank := SoundBank.build()
	for name in ["drop", "land", "sun", "danger", "game_over"]:
		assert_true(bank.has(name), name)
		assert_true(bank[name] is AudioStreamWAV, name)
	for kind in range(1, LanternKinds.COUNT + 1):
		assert_true(bank.has("merge_%d" % kind), "merge_%d" % kind)


func test_sounds_are_short_and_not_silent() -> void:
	var bank := SoundBank.build()
	for name: String in bank:
		var wav: AudioStreamWAV = bank[name]
		assert_eq(wav.format, AudioStreamWAV.FORMAT_16_BITS, name)
		assert_between(wav.get_length(), 0.03, 1.5, name)
		assert_gt(SoundBank.peak(wav), 0.2, name + " is audible")
		assert_lte(SoundBank.peak(wav), 1.0, name + " doesn't clip")


func test_merge_chimes_climb_a_scale() -> void:
	for kind in range(1, LanternKinds.COUNT):
		assert_gt(SoundBank.merge_freq(kind + 1), SoundBank.merge_freq(kind))
	assert_almost_eq(SoundBank.merge_freq(1), 261.63, 0.01)  # middle C
	assert_almost_eq(SoundBank.merge_freq(11), 1046.5, 0.1)  # two octaves up


func test_sfx_plays_and_remembers() -> void:
	var sfx := Sfx.new()
	sfx.settings_path = "user://test_sfx_%d.cfg" % randi()
	add_child_autofree(sfx)
	sfx.play("drop")
	assert_eq(sfx.history, ["drop"])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sfx.settings_path))


func test_mute_silences_and_is_saved() -> void:
	var path := "user://test_sfx_%d.cfg" % randi()
	var sfx := Sfx.new()
	sfx.settings_path = path
	add_child_autofree(sfx)
	sfx.set_muted(true)
	sfx.play("drop")
	assert_eq(sfx.history, [], "nothing plays while muted")
	var again := Sfx.new()
	again.settings_path = path
	add_child_autofree(again)
	assert_true(again.muted)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func test_unknown_sound_is_ignored() -> void:
	var sfx := Sfx.new()
	sfx.settings_path = "user://test_sfx_%d.cfg" % randi()
	add_child_autofree(sfx)
	sfx.play("nope")
	assert_eq(sfx.history, [])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(sfx.settings_path))
