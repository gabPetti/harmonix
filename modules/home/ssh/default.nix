{ config, ... }:

{
  # Holds the key for the session so a passphrase is typed once per login
  # rather than on every fetch and push.
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;

    # Home Manager's implicit "*" defaults are on their way out; carry the ones
    # worth keeping explicitly so a future release can't change them silently.
    enableDefaultConfig = false;

    # Keyed by host pattern, with upstream OpenSSH directive names as values.
    settings = {
      "*" = {
        ForwardAgent = false;
        Compression = false;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
        # Load a key into the agent the first time it is actually used.
        AddKeysToAgent = "yes";
      };

      # IST/RNL GitLab. The account is SSO-only and has no git password, so a
      # key is the only way in.
      "gitlab.rnl.tecnico.ulisboa.pt" = {
        User = "git";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_rsa";
        # Offer only this key: GitLab identifies the account *by* the key it
        # authenticates with, so an agent holding several could log in as the
        # wrong one.
        IdentitiesOnly = true;
      };
    };
  };
}
