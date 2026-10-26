# Balance Log

Tuning of `game/data/balance.json`, using bots that play the real game (real physics) headless:

```bash
godot --headless --fixed-fps 60 --path game --script res://tools/balance_sim.gd -- --bot careful --runs 20
```

There are two bots, each dropping one lantern per second:
- **careful:** aims to land on a matching lantern, and otherwise keeps the pile low.
- **random:** aims anywhere.

Results are written as drops p10/median/p90, then median score, median biggest kind (and max), then the share of runs that made a Sun.

## 2026-10-26 - First pass (agent)

**Target** (the agent's guess at "fun", since the user skipped the questions):
- careful runs last 2–3½ minutes (120–200 drops);
- they usually reach Sky or Moon (kind 9–10);
- the Sun stays a rare trophy (0–10% of runs);
- the random player lasts at most 60% as long and scores at most 40% as much.

The first target asked for 80–150 drops *and* Suns in 5–25% of runs. That can't work: a Sun is 1,024 Embers' worth of lantern, so it needs roughly 350+ drops at the average drop size. The target was revised.

| Config | Careful | Random |
|---|---|---|
| baseline: weights 4,3,3,2,1, danger 2.0 s | 207/**249**/304, 2550, 9 (10), 0% | 116/137/156, 851, 7 (8), 0% |
| weights 4,3,3,2,1, danger 1.5 s | 218/250/315, 2562, 9 (9), 0% | 108/131/155, 786 |
| weights 3,3,3,3,2, danger 2.0 s | 172/197/243, 2281, 9 (10), 0% | 80/107/122, 753 |
| weights 3,3,3,3,2, danger 1.5 s | 167/201/230, 2371, 9 (9), 0% | 84/100/122, 699 |
| weights 2,3,3,3,3, danger 1.5 s | 151/181/230, 2272, 9 (10), 0% | 81/93/104, 691 |
| **chosen: weights 2,3,3,3,3, danger 2.0 s** (40 runs, fresh seeds) | 145/**171**/219, 2073, 9 (10), 0% | 75/92/121, 632, 7 (8) |

**Findings:**
- The danger timer barely changes anything (1.5 s vs 2 s), so it stays at the friendlier 2 s.
- Bigger drops (fewer Embers) are the lever: the jar fills faster, and runs drop from about 4 minutes to about 3.
- The random bot lasts 54% as long and scores 30% as much, so skill clearly matters.
- Neither bot made a Sun in 140 runs. Even Moon is rare (the max), so the Sun is a true trophy.

**Not tuned:** the cooldown (0.45 s), because the bots drop slower than it allows; and the jar size and lantern sizes, which are layout and art.
