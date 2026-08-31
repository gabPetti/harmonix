{ pkgs, config, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';
    shellAliases = {
      ll = "ls -l";
    };

    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    setOptions = [
      "HIST_IGNORE_ALL_DUPS"
    ];
  };

  users.users.gabpetti.shell = pkgs.zsh;
}
