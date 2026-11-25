# "Notes" in the app launcher: one scratch file for jotting things down,
# opened in neovim at its last line so a new note goes straight to the end.
# ~/Notes itself comes from home-layout; nvim creates the file on first save.
{ config, ... }:

let
  notes = "${config.home.homeDirectory}/Notes";
in
{
  xdg.desktopEntries.notes = {
    name = "Notes";
    genericName = "Quick notes";
    comment = "Open ~/Notes/notes.md";
    exec = ''nvim --cmd "cd ${notes}" ${notes}/notes.md'';
    terminal = true;
    icon = "accessories-text-editor";
    categories = [ "Utility" "TextEditor" ];
  };
}
