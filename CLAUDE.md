# CLAUDE.md

Config files for the user's applications, one directory per application. See `README.md` for the overview.

## Editing

- This repository holds only the files themselves. Placing them is each machine's job, so nothing here depends on how a particular machine is set up. Comments state what a file expects from its environment (a command on PATH, a file next to it, a service that handles something), not which repository or file provides it.
- A machine may place pinned copies of this repository instead of linking to the checkout, so an edit here can reach it only after that machine updates its pin and applies. Adding, renaming or removing a file usually needs a matching change on the machine's side too. Tell the user when an edit needs either.
- `claude/skills/writing-style/` is the source of truth for the skill registered on claude.ai. After editing it, tell the user to upload it to claude.ai again. It is not placed in `~/.claude/skills` on any machine, because Claude Code already gets the claude.ai copy. The rule names `claude/writing-lint.nu` reports must match the section headings of its `reference.md`.
- Comments that point to another file use paths relative to the repository root, such as `niri/config.kdl`. Do not point to files outside this repository.
- Keep everything this repository's own scripts read or write inside it. Generated files that other programs read, such as `waybar/circuit/wires.json`, are committed here.

## Commits

Use Conventional Commits with the application directory as the scope: `feat(niri): ...`, `fix(kanata): ...`, `feat(claude): ...`. Omit the scope for repository-wide changes such as `docs`.
