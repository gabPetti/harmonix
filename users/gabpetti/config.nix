{ libs, pkgs, ... }:

{
  users.users."gabpetti" = {
    isNormalUser = true;
    description = "Gabriel Petti Tavares";
    extraGroups = [ "networkmanager" "wheel" "input"];
    packages = with pkgs; [
      vim
      fastfetch
      discord-ptb
      thunderbird
      gh # GitHub CLI
      nodejs
      libnotify
    ];
  };
}
