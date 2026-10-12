# home-manager module: links the configs in config/ into ~.
#
# Every config is a live link straight into this checkout, not a read-only
# store copy: edits take effect immediately and apps can write their own
# config. Trade-off: `darwin-rebuild --rollback` doesn't cover them; use git.
# Expects this repo checked out at ~/dotfiles/public (a submodule of the
# private repo that imports this module).
{ config, ... }:
let
  live = path:
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/public/${path}";
in
{
  # Whole directories: apps that save by replacing a file stay inside the link.
  xdg.configFile."nvim".source = live "config/nvim";
  xdg.configFile."karabiner".source = live "config/karabiner";

  xdg.configFile."alacritty/alacritty.toml".source = live "config/alacritty/alacritty.toml";
  xdg.configFile."neovide/config.toml".source = live "config/neovide/config.toml";

  # Fish files are linked one by one: fish writes machine-local state
  # (fish_variables) next to them, and that must not end up in the repo.
  xdg.configFile."fish/config.fish".source = live "config/fish/config.fish";
  xdg.configFile."fish/conf.d/paths.fish".source = live "config/fish/conf.d/paths.fish";
  xdg.configFile."fish/conf.d/rustup.fish".source = live "config/fish/conf.d/rustup.fish";

  # Only the profile config; the rest of ~/.colima is VM disks and runtime state.
  home.file.".colima/default/colima.yaml".source = live "config/colima/colima.yaml";

  home.file.".gitconfig".source = live "config/git/gitconfig";

  home.file.".zshrc".source = live "config/shell/zshrc";
  home.file.".zshenv".source = live "config/shell/zshenv";
  home.file.".bashrc".source = live "config/shell/bashrc";
  home.file.".bash_profile".source = live "config/shell/bash_profile";
  home.file.".profile".source = live "config/shell/profile";
}
