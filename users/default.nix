{ vars, ... }:

{
  imports = [
    ./${vars.username}/config.nix
  ];
}
