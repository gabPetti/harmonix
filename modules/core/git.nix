{ pkgs, vars, ... }:

let
  # Tokens are per-instance, so each GitLab host reads its own .env key. The
  # value stays in .env rather than /etc/gitconfig: anything written there is
  # world-readable, and a Nix-interpolated secret would also be copied into the
  # store. The helper sources it per invocation instead.
  gitlabTokenHelper = tokenVar:
    "!f() { . ${vars.repoPath}/.env; [ -n \"\${${tokenVar}:-}\" ] || return 0; echo username=\"\${GITLAB_USER:-oauth2}\"; echo password=\"\${${tokenVar}}\"; }; f";
in
{
  # Install Git and CLI utilities system-wide
  environment.systemPackages = with pkgs; [
    git
    git-lfs
    glab
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
      # GITLAB_USER is the account name. gitlab.com ignores the username for
      # token auth, but self-hosted instances can be stricter, so send it when
      # set and fall back to oauth2 otherwise.
      credential."https://gitlab.com".helper = gitlabTokenHelper "GITLAB_HTTPS";
      # IST/RNL GitLab. Only used if an https remote somehow survives the
      # rewrite below; the account is SSO-only, so a token is the sole usable
      # HTTPS credential.
      credential."https://gitlab.rnl.tecnico.ulisboa.pt".helper =
        gitlabTokenHelper "GITLAB_RNL_TOKEN";
      # Course material hands out https clone URLs, but the RNL account
      # authenticates by SSH key. Rewrite rather than retyping every URL.
      url."git@gitlab.rnl.tecnico.ulisboa.pt:".insteadOf =
        "https://gitlab.rnl.tecnico.ulisboa.pt/";
    };
  };

  # glab authenticates from GITLAB_TOKEN. Read out of .env at shell startup so
  # the token never reaches the Nix store or /etc.
  programs.zsh.interactiveShellInit = ''
    if [ -r ${vars.repoPath}/.env ]; then
      export GITLAB_TOKEN="$(${pkgs.gnused}/bin/sed -n "s/^GITLAB_HTTPS=//p" ${vars.repoPath}/.env)"
    fi
  '';
}
