{ libs, pkgs, ... }:

{
  users.users."gargaroth" = {
    isNormalUser = true;
    description = "Gargaroth, The Devourer";
    hashedPasswordFile = "./password.txt";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      discord-ptb
    ];
  };
}
