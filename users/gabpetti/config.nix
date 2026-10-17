{ libs, pkgs, ... }:

{
  users.users."gabpetti" = {
    isNormalUser = true;
    description = "Gabriel Petti Tavares";
    extraGroups = [ "networkmanager" "wheel" "input" "docker" "libvirtd" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      vim
      unzip
      psmisc
      discord-ptb
      gh
      nodejs
      python3
      python3Packages.pip
      python3Packages.holidays
      jdk
      maven
      libnotify
      gnuplot
      btop
      google-cloud-sdk
      vagrant
      steam-run
      aider-chat
    ];
  };
}
