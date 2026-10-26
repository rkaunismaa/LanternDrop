# Lantern Drop - Design Doc (v0.1)

## Pitch
Drop glowing paper lanterns into a glass jar at night. Two lanterns of the same kind that touch merge into the next, bigger and brighter kind. Keep merging to climb to the Sun lantern. If the jar overflows, the night is over. It's one control, short runs, and "just one more go".

## Goals
- As simple as Tetris or Flappy Bird to learn: aim and drop.
- Better looking than Crossroads Inn: glowing light on a dark night, with soft physics, merge bursts and a gentle sway.
- Fun from the first drop: chain merges, a visible next-lantern preview, and a best score to beat.

## Non-goals (for now)
- No levels, power-ups, shop, accounts or online leaderboards.
- No runtime AI.
- Mobile builds may come later; desktop (mouse and keyboard) comes first.

## Controls
- Move the mouse (or press Left/Right or A/D) to aim. Click (or press Space) to drop.
- After a drop there is a short cooldown before the next lantern is ready.

## Lanterns (11 kinds, smallest to largest)
| # | Name | Radius (px) | Points when made |
|---|------|-------------|------------------|
| 1 | Ember | 18 | - |
| 2 | Candle | 24 | 3 |
| 3 | Paper | 31 | 6 |
| 4 | Rice | 39 | 10 |
| 5 | Silk | 48 | 15 |
| 6 | Lotus | 58 | 21 |
| 7 | Dragon | 70 | 28 |
| 8 | Festival | 84 | 36 |
| 9 | Sky | 100 | 45 |
| 10 | Moon | 118 | 55 |
| 11 | Sun | 138 | 66 |

- **Points.** Making a lantern of kind *t* scores t(t+1)/2.
- **Two Suns.** When two Suns touch, they rise away and score a 100-point bonus.
- **What you drop.** Only kinds 1–5 are ever dropped, with weights 4, 3, 3, 2, 1. The next lantern is always shown.

## Rules
- **Merging.** When two lanterns of the same kind touch, both disappear and one lantern of the next kind appears where they met. One lantern can only merge once per moment.
- **Losing.** A danger line sits just below the jar's rim. If any lantern stays above it for 2 seconds in a row, the night ends. Lanterns dropped less than 1 second ago don't count, because they're still falling in.
- **Score.** The best score is saved between sessions.

## Look and feel
- A dark night scene with a glass jar. The lanterns are the only bright things on screen.
- Each kind has its own colour and shape, and gives off soft additive glow.
- On a merge: a quick pop in scale, a burst of sparks, a small screen shake, and a "+points" pop-up.
- Art: the lanterns are drawn in code, which keeps every kind crisp and consistent. The night backdrop (a lake under a starry violet sky) was painted with SDXL on the local ComfyUI (`tools/comfyui/`, recorded in `game/art/provenance.json`). If it's missing, a drawn starry sky shows instead.

## Tech
- Godot 4.7 with typed GDScript, and GUT tests run headless (`tools/run-tests.sh`).
- Rules (kinds, spawning, merging, scoring, the danger timer, best score) live in plain scripts under `game/scripts/rules/`. Physics and visuals live in scenes.

## Open questions
- Balance: how fast the jar fills, whether the drop weights are right, and the cooldown length.
- Sound.
