# Every PATH entry in one place (replaces the universal fish_user_paths).
# fish_add_path puts these in front of the system directories, in this order,
# and skips missing ones. --move also reorders entries already on PATH:
# macOS appends /opt/homebrew/bin after /usr/bin, which would otherwise let
# Apple's bash, python3 and openssl shadow Homebrew's.
fish_add_path --move --path \
    /etc/profiles/per-user/$USER/bin \
    /run/current-system/sw/bin \
    ~/.nix-profile/bin \
    /nix/var/nix/profiles/default/bin \
    /opt/homebrew/opt/llvm/bin \
    /opt/homebrew/bin \
    ~/.ghcup/bin \
    ~/.pack/bin \
    ~/.cargo/bin \
    ~/.local/bin \
    /Applications/Neovide.app/Contents/MacOS

set -gx C_INCLUDE_PATH /opt/homebrew/include
