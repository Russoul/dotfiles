# macOS settings (`defaults write`), applied on every `darwin-rebuild switch`.
# Captured from this Mac on 2026-10-12: only settings that differ from macOS's
# own defaults are listed. Some take effect only after logging out and back in.
# More options: https://nix-darwin.github.io/nix-darwin/manual/ (system.defaults)
{ ... }:
{
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;            # fastest setting in System Settings
      InitialKeyRepeat = 15;    # shortest delay in System Settings
      "com.apple.keyboard.fnState" = true;        # F1–F12 act as function keys
      "com.apple.swipescrolldirection" = false;   # natural scrolling off
    };

    hitoolbox.AppleFnUsageType = "Do Nothing";    # fn/Globe key

    finder.FXPreferredViewStyle = "Nlsv";         # list view

    dock.minimize-to-application = true;

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    # Uncommenting this makes the Dock exactly this list: apps pinned by hand
    # are removed again on the next switch.
    # dock.persistent-apps = [
    #   "/Applications/Claude.app"
    #   "/Applications/Safari.app"
    #   "/Applications/Slack.app"
    #   "/Applications/Neovide.app"
    #   "/Applications/Alacritty.app"
    #   "/Applications/Telegram.app"
    #   "/Applications/WhatsApp.app"
    #   "/Applications/Zulip.app"
    #   "/System/Applications/Photos.app"
    #   "/System/Applications/Mail.app"
    #   "/System/Applications/Calendar.app"
    #   "/System/Applications/Reminders.app"
    #   "/System/Applications/Notes.app"
    #   "/Applications/Xcode.app"
    #   "/System/Applications/Music.app"
    #   "/System/Applications/Messages.app"
    #   "/System/Applications/FaceTime.app"
    #   "/System/Applications/Utilities/Activity Monitor.app"
    #   "/System/Applications/Siri AI.app"
    #   "/System/Applications/System Settings.app"
    #   "/Applications/Xcode.app/Contents/Applications/Instruments.app"
    #   "/Applications/zoom.us.app"
    #   "/Applications/Discord.app"
    # ];
    # dock.persistent-others = [ "/Users/russoul/Downloads" ];
  };
}
