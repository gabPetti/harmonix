# Shared plumbing for this repo's "live dotfiles" pattern.
#
# An app whose config lives under modules/home/<name>/config declares a single
# line -- harmonix.configLinks.<xdg-dir> = "<module-name>"; -- and this module
# turns it into an out-of-store symlink into the working tree.
#
# Because the symlink target is the checkout rather than the Nix store, editing
# anything under modules/home/<name>/config takes effect immediately; only
# changes to a module's own default.nix require a rebuild.
{ config, lib, vars, ... }:

{
  options.harmonix.configLinks = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = { };
    example = {
      nvim = "neovim";
      hypr = "hyprland";
    };
    description = ''
      Maps a directory name under ~/.config to the module directory under
      modules/home whose `config` subdirectory should be symlinked there.
    '';
  };

  config.xdg.configFile = lib.mapAttrs
    (_xdgName: moduleName: {
      source = config.lib.file.mkOutOfStoreSymlink
        "${vars.repoPath}/modules/home/${moduleName}/config";
    })
    config.harmonix.configLinks;
}
