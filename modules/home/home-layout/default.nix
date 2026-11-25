# The shape of ~: one top-level folder per *kind* of thing, topics one level
# down. Declared here so a reinstall recreates it, and so every XDG-aware app
# (file pickers, browsers' download location, screenshot tools) agrees on it.
#
# The second level is shared: a course is uni/<course> under Repos, Documents
# and Notes alike, so everything for one course is one predictable path away
# while each app still gets the root it expects. A finished course moves to
# uni/archive/<course>, keeping the active list to the current semester.
#
# The one exception is this repo, at ~/harmonix (vars.repoPath) rather than
# under Repos: it isn't a project but the source of the system itself, and
# every ~/.config link points into it, so its path is part of the config and
# stays short and fixed.
{ config, lib, vars, ... }:

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
    projects = "${home}/Repos";

    # Nothing here uses them; null stops them being recreated on every switch.
    desktop = null;
    publicShare = null;
    templates = null;

    extraConfig.VMS = "${home}/VMs";
  };

  # xdg-user-dirs-update wrote a plain user-dirs.dirs before this module
  # existed; Home Manager refuses to replace a file it doesn't own.
  xdg.configFile."user-dirs.dirs".force = true;

  systemd.user.tmpfiles.rules = map (dir: "d ${home}/${dir} - - - -") [
    # Where a repo goes is decided by whose it is, not by what it is.
    "Repos/personal"
    "Repos/uni"
    "Repos/forks"

    # Inbox is whatever no rule could place; admin is paperwork that outlives
    # any course (enrolment, residence, insurance, transcripts).
    "Documents/Inbox"
    "Documents/uni/archive"
    "Documents/admin"
    "Documents/books"

    # The one Obsidian vault (modules/home/obsidian).
    "Notes/uni"

    "Pictures/Screenshots"
  ];

  # Without the checkout every out-of-store link (config-links.nix) dangles.
  # A warning rather than a failure: a first install can build from a copy
  # before the repo is cloned into place.
  home.activation.harmonixCheckout = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ ! -d ${lib.escapeShellArg "${vars.repoPath}/.git"} ]; then
      warnEcho "No harmonix checkout at ${vars.repoPath}: the ~/.config links into it dangle until it is cloned there."
    fi
  '';
}
