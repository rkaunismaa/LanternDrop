class_name SimBots
extends RefCounted
## Players for the balance simulation (game/tools/balance_sim.gd). They only choose where to aim;
## the real game decides everything else.


## Where a lantern of this kind dropped at x would come to rest: [center y, the lantern it lands on or null].
static func landing(main: Node2D, x: float, kind: int) -> Array:
	var r := LanternKinds.radius(kind)
	var best_y: float = main.JAR_FLOOR - r
	var support: Lantern = null
	for l: Lantern in main.lanterns():
		var rr := LanternKinds.radius(l.kind) + r
		var dx := absf(l.position.x - x)
		if dx < rr:
			var y := l.position.y - sqrt(rr * rr - dx * dx)
			if y < best_y:
				best_y = y
				support = l
	return [best_y, support]


static func landing_y(main: Node2D, x: float, kind: int) -> float:
	return landing(main, x, kind)[0]


## Drops anywhere: a careless player.
static func random_x(main: Node2D, rng: RandomNumberGenerator) -> float:
	var r := LanternKinds.radius(main.spawner.peek())
	return rng.randf_range(main.JAR_LEFT + r + main.AIM_GAP, main.JAR_RIGHT - r - main.AIM_GAP)


## A careful player: land on a matching lantern if possible, otherwise keep the pile low
## and next to a lantern of the same kind.
static func careful_x(main: Node2D) -> float:
	var kind: int = main.spawner.peek()
	var r := LanternKinds.radius(kind)
	var lo: float = main.JAR_LEFT + r + main.AIM_GAP
	var hi: float = main.JAR_RIGHT - r - main.AIM_GAP
	var candidates: Array[float] = []
	for i in 24:
		candidates.append(lerpf(lo, hi, i / 23.0))
	var twins: Array[Lantern] = []
	for l: Lantern in main.lanterns():
		if l.kind == kind:
			twins.append(l)
			candidates.append(clampf(l.position.x, lo, hi))
	var best_x := candidates[0]
	var best_score := -INF
	for x in candidates:
		var land := landing(main, x, kind)
		var y: float = land[0]
		var score := y  # lower in the jar is better
		if land[1] != null and (land[1] as Lantern).kind == kind:
			score += 2000.0
		else:
			for t in twins:
				var d := Vector2(x, y).distance_to(t.position)
				if d < 3.0 * r + LanternKinds.radius(kind):
					score += 500.0 - d
		if score > best_score:
			best_score = score
			best_x = x
	return best_x
