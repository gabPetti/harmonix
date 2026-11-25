# `harmonix`: the command-line side of this repo. Each subcommand is one module
# under cli/harmonix/commands; their settings live in config/ and are linked to
# ~/.config/harmonix, so tuning them needs no rebuild (changing the code does).
{ pkgs, vars, ... }:

let
  harmonix = pkgs.python3Packages.buildPythonApplication {
    pname = "harmonix";
    version = "0.1.0";
    pyproject = true;
    src = ./cli;
    build-system = [ pkgs.python3Packages.setuptools ];

    makeWrapperArgs = [
      # organize reads repo remotes to decide where a repo belongs.
      "--prefix"
      "PATH"
      ":"
      "${pkgs.lib.makeBinPath [ pkgs.git ]}"
      # The checkout is never moved by organize: every ~/.config symlink
      # points into it, so it only moves together with vars.repoPath.
      "--set"
      "HARMONIX_REPO"
      vars.repoPath
      "--set"
      "HARMONIX_GITHUB_USER"
      vars.githubUser
    ];
  };
in
{
  home.packages = [ harmonix ];

  harmonix.configLinks."harmonix" = "harmonix";
}
