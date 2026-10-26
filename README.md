# Lantern Drop

Drop glowing paper lanterns into a glass jar under a night sky. Two lanterns of the same kind that touch merge into the next, bigger and brighter kind, all the way up to the Sun. If the jar overflows, the night is over.

The second project in a study of the AI-assisted game development workflow; see [`docs/session-history.md`](docs/session-history.md).

## Play

```bash
godot --path game
```

Move the mouse (or press Left/Right or A/D) to aim, then click (or press Space) to drop.

## Develop

```bash
tools/run-tests.sh                      # GUT tests, headless (fails on any script error)
python3 tools/comfyui/generate_assets.py --force   # regenerate the backdrop (ComfyUI must be running)
```

The rules are in `game/scripts/rules/` and the scene is in `game/scenes/`. `docs/design.md` is the source of truth.
