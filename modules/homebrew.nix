# Declarative Brewfile: `darwin-rebuild switch` runs `brew bundle` with this list.
# Generated from `brew bundle dump` on 2026-10-12.
{ ... }:
{
  homebrew = {
    enable = true;
    # Never uninstall packages missing from this list. Switch to "check" (abort
    # on unlisted packages) or "uninstall" once the list is trusted.
    onActivation.cleanup = "none";

    taps = [ "oven-sh/bun" ];

    brews = [
      "zstd"
      "bash"
      "gmp"
      "ghc"
      "cabal-install"
      "chezscheme"
      "clang-format"
      "cmake"
      "colima"
      "docker"
      "docker-compose"
      "fd"
      "fish"
      "python@3.13"
      "fontforge"
      "fzf"
      "gcc"
      "gdb"
      "gh"
      "ghostscript"
      "git-delta"
      "gnupg"
      "gnuplot"
      "haskell-language-server"
      "jemalloc"
      "libffi"
      "llvm"
      "lua-language-server"
      "luarocks"
      "magic-wormhole"
      "mimalloc"
      "moreutils"
      "neovim"
      "openjdk"
      "pkgconf"
      "rclone"
      "ripgrep"
      "rlwrap"
      "sbt"
      "scala-cli"
      { name = "shpool"; restart_service = "changed"; }
      "typst"
      "vscode-langservers-extracted"
      "yaml-language-server"
      "yq"
      { name = "oven-sh/bun/bun"; trusted = true; }
    ];

    casks = [
      "font-terminess-ttf-nerd-font"
      "stats"
    ];

    # Also in the dump, left out for now:
    # - vscode: bamboo.idris2-lsp, russoul.massimult-lsp, russoul.nova
    #   (if `code` is not on PATH, brew bundle installs the VS Code cask)
    # - cargo: bend-lang, hvm, tree-sitter-cli
    #   (brew bundle may pull in Homebrew's rust next to rustup)
    # - npm: @vscode/vsce, corepack, typescript-language-server, typescript
    #   (no nix-darwin option for npm packages)
  };
}
