{ libs, pkgs, ... }:

{
  users.users."gabpetti" = {
    isNormalUser = true;
    description = "Gabriel Petti Tavares";
    extraGroups = [ "networkmanager" "wheel" "input" "docker" "libvirtd"];
    shell = pkgs.zsh;
    packages = with pkgs; [
      vim
      unzip
      discord-ptb
      gh
      nodejs
      python3
      libnotify
      gnuplot
      btop
      google-cloud-sdk
      vagrant
      steam-run
    ];
  };
}
