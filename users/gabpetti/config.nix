{ libs, pkgs, ... }:

{
  users.users."gabpetti" = {
    isNormalUser = true;
    description = "Gabriel Petti Tavares";
    extraGroups = [ "networkmanager" "wheel" "input" "docker"];
    shell = pkgs.zsh;
    packages = with pkgs; [
      vim
      discord-ptb
      gh
      nodejs
      python3
      libnotify
      gnuplot
      btop
      google-cloud-sdk
    ];
  };
}
