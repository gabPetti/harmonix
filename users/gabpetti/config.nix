{ libs, pkgs, ... }:

{
  users.users."gabpetti" = {
    isNormalUser = true;
    description = "Gabriel Petti Tavares";
    extraGroups = [ "networkmanager" "wheel" "input" "docker"];
    packages = with pkgs; [
      vim
      discord-ptb
      thunderbird
      gh # GitHub CLI
      nodejs
      libnotify
    ];
  };
}
