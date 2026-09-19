{ pkgs, ... }:

{
  home.packages = with pkgs; [
    stremio-linux-shell
    mpv # Recomendado ter o MPV instalado para acelerar a reprodução externa se necessário
  ];
}
