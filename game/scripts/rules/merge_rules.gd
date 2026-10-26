class_name MergeRules
extends RefCounted
## What happens when two lanterns touch.

const SUN_BONUS := 100


## {"merge": bool, "kind": int (the new kind), "points": int, "vanish": bool (two Suns rise away)}
static func result(a: int, b: int) -> Dictionary:
	if a != b:
		return {"merge": false, "kind": 0, "points": 0, "vanish": false}
	if a == LanternKinds.COUNT:
		return {"merge": true, "kind": 0, "points": SUN_BONUS, "vanish": true}
	return {"merge": true, "kind": a + 1, "points": LanternKinds.points(a + 1), "vanish": false}
