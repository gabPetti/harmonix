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
      cd = "z";
      ls = "eza --icons --group-directories-first";
    };
    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    setOptions = [
      "HIST_IGNORE_ALL_DUPS"
    ];
  };

  environment.systemPackages = with pkgs; [
    eza
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  users.users.gabpetti.shell = pkgs.zsh;
}
