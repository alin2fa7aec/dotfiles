# dotfiles

[日本語](README.ja.md)

Config files for the applications I use, one directory per application. They do not depend on a particular machine or OS.

How the files are placed is up to each machine. On my NixOS desktop, [yukinimoyuru](https://github.com/alin2fa7aec/yukinimoyuru) reads this repository as a flake input and places the files with home-manager.

## Contents

- Shells and terminal: `nushell/`, `bash/`, `starship.toml`, `wezterm/`
- Editors and tools: `vim/`, `yazi/`
- Wayland desktop: `niri/`, `waybar/`, `fuzzel/`, `swaync/`, `swaylock/`, `theme/` (the shared nordfox palette)
- Input: `kanata/`, `karukan/`
- Claude Code: `claude/` (instructions, settings, skills, keybindings, the status line, and the writing-style lint)

## Claude Code skills

`claude/skills/writing-style/` is the source of the skill registered on claude.ai. After editing it, upload it to claude.ai again; claude.ai then syncs it to the browser and to Claude Code on every machine. Do not edit it on claude.ai, and do not place it in `~/.claude/skills` directly, or Claude Code loads it twice.

## License

[MIT](LICENSE)
