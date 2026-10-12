# dotfiles

The shareable half of my macOS setup: Neovim, fish, Karabiner, Alacritty,
Neovide, git and shell configs, plus [nix-darwin](https://github.com/nix-darwin/nix-darwin)
and [home-manager](https://github.com/nix-community/home-manager) modules that
wire them up. Machine- and work-specific parts (host settings, encrypted
secrets) live in a private repo that includes this one as a git submodule at
`~/dotfiles/public` and imports its modules.

```
home/default.nix            home-manager module: links config/* into ~
modules/macos-defaults.nix  macOS settings (keyboard, scrolling, Finder, Dock, …)
modules/homebrew.nix        declarative Brewfile
modules/shells.nix          login shells, Homebrew on PATH for zsh/bash
config/                     the actual config files
.githooks/pre-commit        gitleaks check that blocks committing plaintext secrets
```

To use the modules from your own flake, add them to `darwinSystem`'s `modules`
and import `home/` in your home-manager user. `home/` links to
`~/dotfiles/public/...`; change the path in `home/default.nix` if you keep the
checkout elsewhere.

## Live links

Every config is a live symlink into the checkout
(`config.lib.file.mkOutOfStoreSymlink`), not a read-only copy in the Nix
store: edits, including ones apps make themselves, take effect immediately
and show up in `git status`. A `darwin-rebuild switch` is only needed when the
Nix files change. The trade-off: `darwin-rebuild --rollback` doesn't restore
config contents; git does.

Some apps save by replacing the file instead of writing through the link,
which turns a link to a single file into a plain file the repo no longer sees.
Linking the whole directory avoids that (nvim, Karabiner). Tested 2026-10-12:

| App | Save keeps a link to a single file |
|---|---|
| git (`git config --global`) | yes |
| gh (`gh config set`) | yes |
| Colima (`colima start`) | yes |
| Claude Code (`/model`) | yes |
| VS Code (settings UI) | yes |
| cabal (`cabal user-config update`) | no: renames the old file away; link its directory instead |

Fish files are linked one by one, not as a directory: fish writes machine-local
state (`fish_variables`) next to them.

## PATH notes

- nix-darwin's `/etc/zprofile` doesn't run `path_helper`, so zsh and bash
  login shells lose `/opt/homebrew/bin` (registered in `/etc/paths.d`).
  `modules/shells.nix` adds it back, between the Nix profiles and `/usr/bin`.
  Without it, GUI apps that start tools via `zsh -l` (Neovide → `nvim`) fail.
- `config/fish/conf.d/paths.fish` keeps all of fish's PATH in one place, using
  `fish_add_path --move` so that Homebrew also beats the system's older `bash`,
  `python3` and `openssl`.

## Neovim

Plugins are pinned in `config/nvim/lazy-lock.json`. `:Lazy update` bumps them
(review with `git diff`, then commit); `:Lazy restore` installs exactly the
locked versions. The config used to live in
[My-NeovimCfg](https://github.com/Russoul/My-NeovimCfg), which keeps its
earlier history.
