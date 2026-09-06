{ config, pkgs, ... }:

{
  home.file.".config/hypr".source = ./hypr;
}
