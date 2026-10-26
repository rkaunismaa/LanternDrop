class_name LanternKinds
extends RefCounted
## The 11 lantern kinds, smallest to largest (docs/design.md). Kind numbers start at 1.

const COUNT := 11
const NAMES: PackedStringArray = ["Ember", "Candle", "Paper", "Rice", "Silk", "Lotus", "Dragon", "Festival", "Sky",
	"Moon", "Sun"]
const RADII: PackedFloat32Array = [18, 24, 31, 39, 48, 58, 70, 84, 100, 118, 138]
const COLORS: Array[Color] = [
	Color("ff4d2e"), Color("ff8a2a"), Color("ffd24a"), Color("fff0b8"), Color("ff7aa8"), Color("d65cff"),
	Color("3fe0c5"), Color("8cf05a"), Color("5ab4ff"), Color("cfe0ff"), Color("ffc21a"),
]


static func radius(kind: int) -> float:
	return RADII[kind - 1]


static func name_of(kind: int) -> String:
	return NAMES[kind - 1]


static func color(kind: int) -> Color:
	return COLORS[kind - 1]


## Points for making a lantern of this kind: t(t+1)/2.
static func points(kind: int) -> int:
	return kind * (kind + 1) / 2
