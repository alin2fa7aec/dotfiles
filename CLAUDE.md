# CLAUDE.md

Config files for the user's applications, one directory per application. See `README.md` for the overview.

## Editing

- This repository holds only the files themselves. Placing them is each machine's job. On the NixOS desktop, the `yukinimoyuru` repository reads this one as a flake input (`inputs.dotfiles`) and places the files from `home/alin.nix` and `hosts/desktop/configuration.nix`. Adding, renaming or removing a file here usually needs a matching change there.
- On that desktop, most placed files are store copies pinned by yukinimoyuru's `flake.lock`, so an edit here reaches them only after `nix flake update dotfiles` and a rebuild there. A few files (the global `CLAUDE.md`, the `commit-message` skill, `keybindings.json`, `statusline.sh`) are linked straight to the checkout at `~/!metier/dotfiles`, so edits to them take effect at once.
- `claude/skills/writing-style/` is the source of truth for the skill registered on claude.ai. After editing it, tell the user to upload it to claude.ai again. It is not placed in `~/.claude/skills` on any machine, because Claude Code already gets the claude.ai copy. The rule names `claude/writing-lint.nu` reports must match the section headings of its `reference.md`.
- Comments that point to another file use paths relative to the repository root, such as `niri/config.kdl`. Paths into yukinimoyuru start with `yukinimoyuru/`, such as `yukinimoyuru/home/alin.nix`.
- Keep everything this repository's own scripts read or write inside it. Files yukinimoyuru needs from here, such as `waybar/circuit/wires.json`, are generated here and read there through `inputs.dotfiles`.

## Commits

Use Conventional Commits with the application directory as the scope: `feat(niri): ...`, `fix(kanata): ...`, `feat(claude): ...`. Omit the scope for repository-wide changes such as `docs`.
