class_name SoundBank
extends RefCounted
## Every sound in the game, synthesized in code at startup: no audio files, nothing to license,
## and each sound is tuned by the numbers below.

const RATE := 44100
const PEAK := 0.8  ## every sound is normalized to this level
## Merge chimes climb a major pentatonic scale from middle C, two octaves over the 11 kinds.
const SCALE: PackedInt32Array = [0, 2, 4, 7, 9, 12, 14, 16, 19, 21, 24]
const MIDDLE_C := 261.63


static func merge_freq(kind: int) -> float:
	return MIDDLE_C * pow(2.0, SCALE[kind - 1] / 12.0)


## name -> AudioStreamWAV: drop, land, merge_1..merge_11, sun, danger, game_over.
static func build() -> Dictionary:
	var bank := {
		"drop": _wav(_drop()),
		"land": _wav(_land()),
		"sun": _wav(_notes([MIDDLE_C * 2, MIDDLE_C * 2.52, MIDDLE_C * 3, MIDDLE_C * 4], 0.1, 0.9)),
		"danger": _wav(_danger()),
		"game_over": _wav(_notes([392.0, 329.63, 261.63], 0.25, 1.2)),
	}
	for kind in range(1, LanternKinds.COUNT + 1):
		bank["merge_%d" % kind] = _wav(_bell(merge_freq(kind), 0.7))
	return bank


## Loudest sample of a sound, 0..1 (for tests).
static func peak(wav: AudioStreamWAV) -> float:
	var m := 0
	for i in range(0, wav.data.size(), 2):
		m = maxi(m, absi(wav.data.decode_s16(i)))
	return m / 32768.0


## A soft bell: a few inharmonic partials with a quick attack and exponential decay.
static func _bell(freq: float, seconds: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(seconds * RATE))
	for i in out.size():
		var t := float(i) / RATE
		var env := minf(1.0, t / 0.005) * exp(-t * 5.0)
		out[i] = env * (sin(TAU * freq * t) + 0.4 * sin(TAU * freq * 2.0 * t) * exp(-t * 4.0)
			+ 0.2 * sin(TAU * freq * 2.76 * t) * exp(-t * 8.0))
	return out


## Bells one after another (arpeggios and the game-over phrase).
static func _notes(freqs: Array, gap: float, seconds: float) -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(seconds * RATE))
	for n in freqs.size():
		var start := int(n * gap * RATE)
		var bell := _bell(freqs[n], seconds - n * gap)
		for i in bell.size():
			if start + i < out.size():
				out[start + i] += bell[i]
	return out


## A soft falling "plip" as a lantern is let go.
static func _drop() -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(0.14 * RATE))
	var phase := 0.0
	for i in out.size():
		var t := float(i) / RATE
		phase += TAU * lerpf(320.0, 160.0, t / 0.14) / RATE
		out[i] = minf(1.0, t / 0.004) * exp(-t * 22.0) * sin(phase)
	return out


## A gentle wooden "tok": a low thump plus a little filtered noise.
static func _land() -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(0.09 * RATE))
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var noise := 0.0
	for i in out.size():
		var t := float(i) / RATE
		noise = lerpf(noise, rng.randf_range(-1.0, 1.0), 0.15)  # simple low-pass
		out[i] = exp(-t * 45.0) * (sin(TAU * 140.0 * t) + 0.6 * noise)
	return out


## A soft low pulse for the overflow warning.
static func _danger() -> PackedFloat32Array:
	var out := PackedFloat32Array()
	out.resize(int(0.22 * RATE))
	for i in out.size():
		var t := float(i) / RATE
		out[i] = sin(PI * t / 0.22) * (sin(TAU * 98.0 * t) + 0.3 * sin(TAU * 196.0 * t))
	return out


static func _wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var loudest := 0.0
	for s in samples:
		loudest = maxf(loudest, absf(s))
	var gain := PEAK / loudest if loudest > 0.0 else 1.0
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i] * gain, -1.0, 1.0) * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	wav.data = data
	return wav
