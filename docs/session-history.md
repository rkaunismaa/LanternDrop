# Session History

A running, step-by-step record of everything done in the Claude Code terminal sessions on this project, in order. The project began inside the Crossroads Inn session; see that repo's `docs/session-history.md` for everything before step 1.

---

## Session 1 - 2026-10-26

### 1. "...starting again but with a whole new game ... simplicity of something like tetris or flappy birds. Suggest something." / "lantern drop" / "just do it"
- After finishing Crossroads Inn, the user asked for a new game that's better looking, more fun and very simple. The agent proposed four concepts: Lantern Drop (a Suika-style merge game), Moth (one-button flight), Orbit Hop and Stack the Tower. It recommended Lantern Drop, and the user picked it.
- The user skipped the questions. The agent's calls:
  - a separate project in `~/Data2/GameProjects/LanternDrop` with its own local git repo (no GitHub repo unless asked);
  - Godot 4.7 with rules in tested plain scripts;
  - lanterns drawn in code first, then ComfyUI art;
  - this session history kept from the start.
- Scaffolded the project:
  - `project.godot`: portrait 720x1080 shown in a 540x810 window, physics at 120 ticks a second, and a dark night clear colour;
  - GUT and `tools/run-tests.sh` copied from Crossroads Inn (without the LLM switch);
  - `.gitignore`, `CLAUDE.md`, and `docs/design.md` v0.1 (11 lantern kinds, merging, scoring, the danger line, look and feel).

### 2. Rules, test-first
- Wrote 13 failing GUT tests, then implemented `LanternKinds` (11 kinds: radius, colour, name, points), `MergeRules` (same kinds merge; two Suns vanish for 100), `Spawner` (kinds 1-5 weighted 4,3,3,2,1, seeded, with a next-lantern preview), `DangerWatch` (2 s above the line, ignoring lanterns under 1 s old, plus a 0-1 warning level) and `BestScore` (saved in `user://`). 13/13 passing.
