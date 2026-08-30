{ pkgs, ... }:

{
  # Install Git and CLI utilities system-wide
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    gh # GitHub CLI
  ];

  # Writes system-wide defaults to /etc/gitconfig
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "gabpetti";
        email = "gabpettidev@gmail.com";
      };
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
      push = {
        autoSetupRemote = true;
      };
      core = {
        editor = "nvim"; # or "vim", "nano", etc.
      };
    };
  };
}
