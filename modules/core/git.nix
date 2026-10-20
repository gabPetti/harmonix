{ pkgs, vars, ... }:

{
  # Install Git and CLI utilities system-wide
  environment.systemPackages = with pkgs; [
    git
    git-lfs
  ];

  # Writes system-wide defaults to /etc/gitconfig
  programs.git = {
    enable = true;
    config = {
      user = {
        name = vars.username;
        email = vars.email;
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
