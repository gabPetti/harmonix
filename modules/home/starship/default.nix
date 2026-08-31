{ pkgs, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Custom prompt format using styled modules
      format = lib.concatStrings [
        "[░▒▓](#89b4fa)"
        "[  ](bg:#89b4fa fg:#1e1e2e)"
        "[](bg:#313244 fg:#89b4fa)"
        "$directory"
        "[](bg:#45475a fg:#313244)"
        "$git_branch"
        "$git_status"
        "[](bg:#585b70 fg:#45475a)"
        "$nix_shell"
        "$nodejs"
        "$rust"
        "$python"
        "$golang"
        "[](fg:#585b70)"
        "\n$character"
      ];

      # Global options
      add_newline = true;

      # Directory configuration
      directory = {
        style = "bg:#313244 fg:#cdd6f4 bold";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󱔗 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
          "Projects" = "󰲋 ";
        };
      };

      # Git branch & status
      git_branch = {
        symbol = "";
        style = "bg:#45475a fg:#a6e3a1 bold";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bg:#45475a fg:#f38ba8";
        format = "[$all_status$ahead_behind ]($style)";
        modified = " ";
        staged = " ";
        untracked = " ";
        deleted = " ";
      };

      # Nix Shell indicator
      nix_shell = {
        symbol = "";
        style = "bg:#585b70 fg:#89b4fa bold";
        format = "[ $symbol ($name) ]($style)";
      };

      # Language badges
      nodejs = {
        symbol = "";
        style = "bg:#585b70 fg:#a6e3a1";
        format = "[ $symbol ($version) ]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:#585b70 fg:#fab387";
        format = "[ $symbol ($version) ]($style)";
      };

      python = {
        symbol = "";
        style = "bg:#585b70 fg:#f9e2af";
        format = "[ $symbol ($version) ]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:#585b70 fg:#89dceb";
        format = "[ $symbol ($version) ]($style)";
      };

      # Prompt character
      character = {
        success_symbol = "[󰄾](bold #a6e3a1)";
        error_symbol = "[󰄾](bold #f38ba8)";
        vimcmd_symbol = "[󰄾](bold #cba6f7)";
      };

      # Command execution time
      cmd_duration = {
        min_time = 2000;
        style = "fg:#f9e2af italic";
        format = "[  $duration ]($style)";
      };
    };
  };
}
