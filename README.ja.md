# dotfiles

[English](README.md)

使っているアプリケーションの設定ファイル。アプリケーションごとにディレクトリを分けている。特定のマシンや OS には依存しない。

どう配置するかは各マシンの側で決める。NixOS のデスクトップでは、[yukinimoyuru](https://github.com/alin2fa7aec/yukinimoyuru) がこのリポジトリを flake の input として読み、home-manager で配置している。

## 内容

- シェルとターミナル: `nushell/`, `bash/`, `starship.toml`, `wezterm/`
- エディターとツール: `vim/`, `yazi/`
- Wayland のデスクトップ: `niri/`, `waybar/`, `fuzzel/`, `swaync/`, `swaylock/`, `theme/` (共有する nordfox のパレット)
- 入力: `kanata/`, `karukan/`
- Claude Code: `claude/` (指示、設定、スキル、キーバインド、ステータスライン、文章スタイルの lint)

## Claude Code のスキル

`claude/skills/writing-style/` は、claude.ai に登録しているスキルの正本である。編集したら claude.ai にアップロードし直す。claude.ai から、ブラウザーと各マシンの Claude Code に同期される。claude.ai 上では編集しない。また、`~/.claude/skills` に直接配置すると Claude Code が2重に読み込むため、配置しない。

## ライセンス

[MIT](LICENSE)
