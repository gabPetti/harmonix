# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

"Harmonix" is a personal NixOS flake configuration (a system + dotfiles repo), not an application. There is no build/test/lint tooling in the traditional sense — changes are validated by rebuilding the NixOS system.

## Common commands

- Rebuild and switch to the new config: `sudo nixos-rebuild switch --flake .#laptop`
- Dry-build without activating (good for validating syntax/evaluation before switching): `nixos-rebuild build --flake .#laptop`
- Update flake inputs: `nix flake update`
- Format a `.nix` file: `nixpkgs-fmt <file>` (available via the neovim module's packages, used as the Nix formatter)
- Generate a user's login password hash (`users/<name>/password.txt`, gitignored): `./setup.sh`

There is only one host defined in `flake.nix`: `laptop` (`nixosConfigurations.laptop`).

## Architecture

The repo is a flake whose single entrypoint (`flake.nix`) builds `laptop` via `nixpkgs.lib.nixosSystem`, with Home Manager wired in as a NixOS module (`home-manager.useGlobalPkgs`/`useUserPackages = true`) rather than run standalone. Config is layered as:

- `hosts/laptop/configuration.nix` — host entrypoint; imports hardware config, `users/default.nix`, `modules/core/default.nix`, and `modules/system/hyprland.nix`.
- `modules/core/` — system-level NixOS modules (audio, bluetooth, boot, display-manager, firewall, fonts, git, internationalisation, network, nix-ld, virtualization, xdg, zsh), aggregated through `modules/core/default.nix`. Add a new system-wide concern here and register it in that `default.nix`.
- `modules/system/` — desktop-environment-level modules (`hyprland.nix`, `gnome.nix`). Only `hyprland.nix` is currently imported by the host; `gnome.nix` is an alternative, not wired in.
- `modules/home/<name>/` — one Home Manager module per app/tool, each with its own `default.nix`. `users/gabpetti/home.nix` is the list of which ones are enabled for this user.
- `users/default.nix` imports per-user NixOS account definitions (`users/<name>/config.nix`, e.g. `users.users."gabpetti"` with packages/shell/groups). `users/<name>/home.nix` is the Home Manager profile for that same user, referenced from `flake.nix`'s `home-manager.users`.

### The dotfile symlink pattern

Most `modules/home/<name>/default.nix` files do NOT let Home Manager generate config files into the Nix store. Instead they do:

```nix
xdg.configFile."<app>".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/<name>/config";
```

This symlinks `~/.config/<app>` straight to the `config/` directory inside this repo (see `hyprland`, `neovim`, `matugen`, `waybar`, `kitty`, `swaync`, `yazi`, `fastfetch`). Practical implications:
- Editing files under a module's `config/` directory takes effect immediately for that app (no rebuild needed) — only changing `default.nix` (packages, the symlink itself, env vars, services) requires a rebuild.
- This assumes the repo lives at `~/harmonix` — paths are hardcoded, not derived from `self`/flake path.

### Theming via matugen

`modules/home/matugen/config/templates/*` are Material-You color templates matugen renders out to `matugen-colors.*` files consumed by `hyprland`, `waybar`, `kitty`, `swaync`, `gtk3`/`gtk4`, `hyprlock`, `yazi`, and KDE. Generated `matugen-colors.*` files are gitignored (see `.gitignore`) — don't hand-edit them; edit the template instead.

### Secrets

`.env` (gitignored) holds `OPENROUTER_API_KEY` and `EDUROAM_PASSWORD`; `.env.example` documents the expected keys. `modules/core/network.nix` wires `/home/gabpetti/harmonix/.env` into NetworkManager's `eduroam` profile via `environmentFiles` so `$EDUROAM_PASSWORD` resolves at connection time. Never commit real values into `.env.example` or into any `.nix` file.

### Per-user password files

`setup.sh` generates yescrypt password hashes into `users/<name>/password.txt` (gitignored, mode 600) for use with NixOS's hashed-password mechanism — don't put plaintext passwords in any tracked file.
