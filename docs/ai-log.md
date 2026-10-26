# AI Log

Short notes on what the agent did, what was fixed by hand, and rough time spent.

## 2026-10-26 - First playable version
- Agent:
  - proposed 4 simple game concepts, and the user picked Lantern Drop;
  - scaffolded a new Godot project with GUT from Crossroads Inn;
  - built the rules (13 tests) and the physics scene (11 tests) test-first, with code-drawn glowing lanterns and juice (sparks, shake, pop-ups);
  - generated a painted backdrop with ComfyUI.
- What worked: watching a scripted run in screenshots found a game-ending bug the tests missed. Lanterns dropped flush against the glass stuck there by friction. Tracing the stuck lantern's position, speed and contacts pointed straight at the cause.
- What went wrong and was fixed by the agent:
  - one wrong test (two Suns can't fit side by side, and it checked the score a frame early);
  - GDScript type-inference errors in tests;
  - the first backdrop had big lanterns floating in the sky, which competed with the gameplay lanterns, so it was regenerated without them.
- Fixed by hand: nothing. Time: about 1 hour.
