# Login shells and PATH for zsh/bash on a nix-darwin Mac with Homebrew.
{ lib, ... }:
{
  # nix-darwin's /etc/zprofile doesn't run path_helper, so zsh and bash login
  # shells ignore /etc/paths.d, where Homebrew registers itself. Without this,
  # apps that start tools via `zsh -l` (Neovide → nvim) can't find Homebrew's.
  # Order 1100: after the Nix profiles (1000), before /usr/bin etc. (1200).
  environment.systemPath = lib.mkOrder 1100 [ "/opt/homebrew/bin" "/opt/homebrew/sbin" ];

  # Shells allowed as login shells (/etc/shells). The login shell itself (fish)
  # is set once per machine with `chsh -s /opt/homebrew/bin/fish`: declaring it
  # here would require nix-darwin to fully manage the user account.
  environment.shells = [
    "/opt/homebrew/bin/bash"
    "/opt/homebrew/bin/fish"
  ];
}
