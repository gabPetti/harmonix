{ libs, pkgs, ... }:

{
  users.users."gabpetti" = {
    isNormalUser = true;
    description = "Gabriel Petti Tavares";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      discord-ptb
      thunderbird
      gh # GitHub CLI
    ];
  };
}
