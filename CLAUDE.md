# Lantern Drop

A small Suika-style merge game: drop glowing lanterns into a jar; same kinds merge into bigger ones. Second project in a study of the AI-assisted game development workflow (the first was Crossroads Inn).

## Tech
- Engine: Godot 4.x (GDScript). Use typed variables. Never use Godot 3 syntax or APIs.
- Platform: Ubuntu Linux. Run headless where possible.
- Tests: GUT (vendored in `game/addons/gut`), run headless with `tools/run-tests.sh` (fails on any script error). Tests in `game/tests/unit/`.
- Keep game rules in plain scripts (`game/scripts/rules/`, RefCounted) separate from physics/UI so they can be tested without the editor.

## Working rules
- Read `docs/design.md` before gameplay changes; it is the source of truth. Update it in the same commit when a decision changes.
- Commit small and often.
- Keep `docs/session-history.md` updated with every step done in the terminal (the user's request, then what was done and the result).
- Keep a short log of AI successes/failures in `docs/ai-log.md`.

## Layout
- `docs/` design doc, session history, AI log
- `game/` Godot project: `scripts/rules/` (rules), `scenes/` (physics, visuals, UI), `art/` (generated)
- `tools/` helper scripts
