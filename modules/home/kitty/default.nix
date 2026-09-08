{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    extraConfig = ''
      window_padding_width 10
      confirm_os_window_close 0
    '';
  };
}
