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

## 2026-10-26 - Sound effects
- Agent: proposed sounds generated in code (no files to license) and got the go-ahead. Built test-first on the branch `sound`:
  - `SoundBank` synthesizes drop, landing, 11 pentatonic merge chimes, the Sun arpeggio, the danger pulse and the game-over phrase as 16-bit WAVs in memory;
  - `Sfx` is an 8-voice player with a mute that is saved between sessions;
  - main-scene hooks, plus the M key and a Sound button.

  12 new tests, 38 in total.
- What went wrong and was fixed by the agent: the landing sound never played. The agent measured instead of guessing: the touch signal fires after the collision is resolved, so the speed read 34 instead of the 686 just before impact. Each lantern now remembers its speed from before the physics step.
- Limit: the agent can't hear the sounds. It checked they're generated, triggered, audible and unclipped, but the user needs to judge how they sound.
- Fixed by hand: nothing. Time: about 30 minutes.
