{ ... }:

{
  programs.obsidian = {
    enable = true;

    # Its own top-level folder rather than under Documents: notes are written,
    # documents are received, and one vault is what keeps links and search
    # whole (home-layout).
    vaults.notes.target = "Notes";

    defaultSettings.app = {
      alwaysUpdateLinks = true;
      spellcheck = true;
    };
  };
}
