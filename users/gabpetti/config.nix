{ libs, pkgs, ... }:

{
  users.users."gabpetti" = {
    isNormalUser = true;
    description = "Gabriel Petti Tavares";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      vim
      fastfetch
      discord-ptb
      thunderbird
      gh # GitHub CLI
      nodejs
    ];
  };
}
