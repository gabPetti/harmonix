{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # FHS-wrapped variant so extensions with prebuilt binaries work unpatched.
    antigravity-ide-fhs
  ];
}
