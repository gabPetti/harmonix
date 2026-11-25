# The shape of ~: one top-level folder per *kind* of thing, topics one level
# down. Declared here so a reinstall recreates it, and so every XDG-aware app
# (file pickers, browsers' download location, screenshot tools) agrees on it.
#
# `harmonix organize` (modules/home/harmonix) is what keeps files in it.
{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    documents = "${home}/Documents";
    download = "${home}/Downloads";
    pictures = "${home}/Pictures";
    videos = "${home}/Videos";
    music = "${home}/Music";
    # XDG's "projects" slot is where file pickers and IDEs look for code.
    projects = "${home}/Code";

    # Nothing here uses them; null stops them being recreated on every switch.
    desktop = null;
    publicShare = null;
    templates = null;

    extraConfig.VMS = "${home}/VMs";
  };

  # xdg-user-dirs-update wrote a plain user-dirs.dirs before this module
  # existed; Home Manager refuses to replace a file it doesn't own.
  xdg.configFile."user-dirs.dirs".force = true;

  # The second level that matters for finding things: where a repo goes is
  # decided by whose it is (see harmonix organize's [code] groups).
  systemd.user.tmpfiles.rules = map (dir: "d ${home}/${dir} - - - -") [
    "Code/personal"
    "Code/uni"
    "Code/forks"
    "Documents/Inbox"
    "Pictures/Screenshots"
  ];
}
