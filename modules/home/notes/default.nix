# "Notes" in the app launcher: one scratch file for jotting things down,
# opened in neovim at its last line so a new note goes straight to the end.
# ~/Notes itself comes from home-layout; nvim creates the file on first save.
{ config, ... }:

{
  xdg.desktopEntries.notes = {
    name = "Notes";
    genericName = "Quick notes";
    comment = "Open ~/Notes/notes.md";
    exec = "nvim + ${config.home.homeDirectory}/Notes/notes.md";
    # The launcher wraps Terminal=true entries in kitty itself.
    terminal = true;
    icon = "accessories-text-editor";
    categories = [ "Utility" "TextEditor" ];
  };
}
